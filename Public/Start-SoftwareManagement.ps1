<#
.SYNOPSIS
    Interactive tool for managing installed software on Windows systems.

.COMPONENT
    QuickSoft
    
.DESCRIPTION
    Provides a text-based user interface for listing, searching, and uninstalling software
    installed on Windows systems. Supports both 32-bit and 64-bit applications, and handles
    both MSI and executable-based uninstallers.

.EXAMPLE
    Start-SoftwareManagement
    Launches the interactive software management interface.

.OUTPUTS
    None. This function provides an interactive interface and displays results directly.

.NOTES
    Name: Start-SoftwareManagement
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-02-03
    
    Requires -RunAsAdministrator


#>
function Start-SoftwareManagement {
    [CmdletBinding()]
    param()

    begin {
        # Check for admin privileges
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            throw "This function requires administrator privileges. Please run PowerShell as Administrator."
        }

        function Get-InstalledSoftware {
            [CmdletBinding()]
            param(
                [Parameter(Position = 0)]
                [SupportsWildcards()]
                [string]$DisplayName = "*"
            )

            try {
                Write-Verbose "Searching for software matching pattern: $DisplayName"
                
                $uninstallKeys = @(
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
                )

                $results = @()
                foreach ($key in $uninstallKeys) {
                    Write-Verbose "Scanning registry key: $key"
                    
                    Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | 
                    Where-Object { $_.DisplayName -like $DisplayName -and $_.UninstallString } |
                    ForEach-Object {
                        $GUID = if ($_.UninstallString -match '{[A-Z0-9-]+}') { $matches[0] }
                        $results += [PSCustomObject]@{
                            DisplayName = $_.DisplayName
                            Publisher = $_.Publisher
                            Architecture = if($key -like "*Wow6432Node*") {"32-bit"} else {"64-bit"}
                            GUID = $GUID
                            Version = $_.DisplayVersion
                            UninstallString = $_.UninstallString
                            QuietUninstallString = $_.QuietUninstallString
                        }
                    }
                }
                
                Write-Verbose "Found $($results.Count) matching software entries"
                return @($results)
            }
            catch {
                Write-Error "Failed to retrieve software list: $_"
                return @()
            }
        }

        function Invoke-SoftwareUninstall {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory = $true)]
                [array]$SelectedSoftware
            )
            
            $total = $SelectedSoftware.Count
            $current = 0
            
            foreach ($software in $SelectedSoftware) {
                $current++
                Write-Host "`nUninstalling ($current/$total): $($software.DisplayName)..." -ForegroundColor Yellow
                Write-Verbose "Processing uninstall for: $($software.DisplayName)"
                
                try {
                    $uninstallCmd = if ($software.QuietUninstallString) { 
                        $software.QuietUninstallString 
                    } else { 
                        $software.UninstallString 
                    }

                    if ($software.GUID) {
                        Write-Verbose "Using MSI uninstall with GUID: $($software.GUID)"
                        Write-Host "  [MSI] Using product code: $($software.GUID)" -ForegroundColor Cyan
                        $process = Start-Process "msiexec.exe" -ArgumentList "/x $($software.GUID) /quiet" -Wait -PassThru
                        
                        if ($process.ExitCode -ne 0) {
                            throw "MSI uninstall failed with exit code: $($process.ExitCode)"
                        }
                    }
                    else {
                        Write-Verbose "Parsing executable uninstall string: $uninstallCmd"
                        Write-Host "  [EXE] Parsing uninstall string" -ForegroundColor Cyan
                        
                        if ($uninstallCmd -match '^"(.+?)"') {
                            $exe = $matches[1]
                            $args = $uninstallCmd.Substring($exe.Length + 2)
                        }
                        else {
                            $exe = ($uninstallCmd -split ' ')[0]
                            $args = $uninstallCmd.Substring($exe.Length)
                        }

                        Write-Verbose "Launching uninstaller: $exe $args"
                        Write-Host "  Executing: $exe" -ForegroundColor DarkCyan
                        Write-Host "  Arguments: $args" -ForegroundColor DarkCyan
                        
                        $process = Start-Process -FilePath $exe -ArgumentList $args -PassThru
                        
                        # Timeout handling
                        $timeout = New-TimeSpan -Minutes 5
                        $sw = [System.Diagnostics.Stopwatch]::StartNew()
                        
                        while (-not $process.HasExited -and $sw.Elapsed -lt $timeout) {
                            Write-Host "." -NoNewline -ForegroundColor Yellow
                            Start-Sleep -Seconds 1
                        }
                        
                        if (-not $process.HasExited) {
                            Write-Warning "Uninstall process timed out after 5 minutes"
                            $process.Kill()
                            throw "Uninstall process timed out"
                        }
                    }
                    
                    Write-Host "`n  Uninstall completed successfully!" -ForegroundColor Green
                    Write-Verbose "Successfully uninstalled: $($software.DisplayName)"
                }
                catch {
                    Write-Error "Failed to uninstall $($software.DisplayName): $_"
                    $choice = Read-Host "  Retry with MSI? (Y/N)"
                    if ($choice -eq 'Y' -and $uninstallCmd -match '{[A-Z0-9-]+}') {
                        Write-Verbose "Attempting MSI fallback with GUID: $($matches[0])"
                        Start-Process "msiexec.exe" -ArgumentList "/x $($matches[0]) /quiet" -Wait
                    }
                }
                
                Start-Sleep -Seconds 1
            }
        }
    }

    process {
        try {
            # Main menu loop
            while ($true) {
                Clear-Host
                Write-Host "=== SOFTWARE MANAGEMENT TOOL ===" -ForegroundColor Cyan
                Write-Host " 1. List All Installed Software" -ForegroundColor Yellow
                Write-Host " 2. Search Software" -ForegroundColor Yellow
                Write-Host " 3. Exit`n" -ForegroundColor Yellow
                $choice = Read-Host "Enter your choice (1-3)"

                switch ($choice) {
                    '1' { 
                        :listLoop while ($true) {
                            Clear-Host
                            Write-Host "=== ALL INSTALLED SOFTWARE ===" -ForegroundColor Cyan
                            Write-Verbose "Retrieving complete software list"
                            $software = Get-InstalledSoftware
                            
                            if ($software.Count -eq 0) {
                                Write-Host "No software found!" -ForegroundColor Yellow
                            }
                            else {
                                for ($i = 0; $i -lt $software.Count; $i++) {
                                    Write-Host " $($i+1)." -NoNewline -ForegroundColor Cyan
                                    Write-Host " $($software[$i].DisplayName)" -NoNewline
                                    Write-Host " [$($software[$i].Version)]" -ForegroundColor DarkGray
                                }
                            }

                            Write-Host "`n=== OPTIONS ===" -ForegroundColor Cyan
                            Write-Host " [Numbers] Select items to uninstall (e.g., 1,3)"
                            Write-Host " R         Refresh list"
                            Write-Host " B         Back to main menu`n"
                            $selection = Read-Host "Enter choice"

                            switch -Regex ($selection.ToUpper()) {
                                '^\d+(,\d+)*$' {
                                    $indices = $selection -split ',' | ForEach-Object { [int]$_ - 1 }
                                    $selected = $software[$indices]
                                    if (-not $selected) { 
                                        Write-Warning "Invalid selection!"
                                        Start-Sleep -Seconds 2
                                        continue 
                                    }
                                    
                                    $confirmation = Read-Host "Uninstall $($selected.Count) items? (Y/N)"
                                    if ($confirmation -eq 'Y') { 
                                        Write-Verbose "Initiating uninstall for $($selected.Count) items"
                                        Invoke-SoftwareUninstall $selected 
                                    }
                                }
                                'R' { continue }
                                'B' { break listLoop }
                                default { 
                                    Write-Warning "Invalid input!"
                                    Start-Sleep -Seconds 1 
                                }
                            }
                        }
                    }

                    '2' {
                        :searchLoop while ($true) {
                            Clear-Host
                            Write-Host "=== SOFTWARE SEARCH ===" -ForegroundColor Cyan
                            $searchTerm = Read-Host "Enter search term (or 'B' to cancel)"
                            if ($searchTerm -eq 'B') { break }

                            Write-Verbose "Searching for software matching: $searchTerm"
                            $software = @(Get-InstalledSoftware -DisplayName "*$searchTerm*")
                            
                            if ($software.Count -eq 0) {
                                Write-Host "No matches found!" -ForegroundColor Yellow
                                Start-Sleep -Seconds 2
                                continue
                            }

                            Clear-Host
                            Write-Host "=== SEARCH RESULTS ===" -ForegroundColor Cyan
                            for ($i = 0; $i -lt $software.Count; $i++) {
                                Write-Host " $($i+1)." -NoNewline -ForegroundColor Cyan
                                Write-Host " $($software[$i].DisplayName)" -NoNewline
                                Write-Host " [$($software[$i].Version)]" -ForegroundColor DarkGray
                            }

                            Write-Host "`n=== OPTIONS ===" -ForegroundColor Cyan
                            Write-Host " [Numbers] Select items to uninstall (e.g., 1,3)"
                            Write-Host " S         New search"
                            Write-Host " B         Back to main menu`n"
                            $selection = Read-Host "Enter choice"

                            switch -Regex ($selection.ToUpper()) {
                                '^\d+(,\d+)*$' {
                                    $indices = $selection -split ',' | ForEach-Object { [int]$_ - 1 }
                                    $selected = $software[$indices]
                                    if (-not $selected) { 
                                        Write-Warning "Invalid selection!"
                                        Start-Sleep -Seconds 2
                                        continue 
                                    }
                                    
                                    $confirmation = Read-Host "Uninstall $($selected.Count) items? (Y/N)"
                                    if ($confirmation -eq 'Y') { 
                                        Write-Verbose "Initiating uninstall for $($selected.Count) items"
                                        Invoke-SoftwareUninstall $selected 
                                    }
                                }
                                'S' { continue }
                                'B' { break searchLoop }
                                default { 
                                    Write-Warning "Invalid input!"
                                    Start-Sleep -Seconds 1 
                                }
                            }
                        }
                    }

                    '3' { 
                        Write-Host "Goodbye!" -ForegroundColor Cyan
                        return 
                    }

                    default {
                        Write-Warning "Invalid choice!"
                        Start-Sleep -Seconds 1
                    }
                }
            }
        }
        catch {
            Write-Error "An unexpected error occurred: $_"
        }
    }

    end {
        Write-Verbose "Software Management session ended"
    }
}

