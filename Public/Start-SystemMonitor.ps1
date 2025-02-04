<#
.SYNOPSIS
    Monitors system for software and process changes.
    
.COMPONENT
    QuickSoft

.DESCRIPTION
    Provides real-time monitoring of:
    - Software installations and uninstallations
    - Process starts and stops
    Logs all changes to a specified file and displays them in the console.

.PARAMETER OutPath
    The directory where the log file will be created.
    Defaults to the system drive (typically C:).

.EXAMPLE
    Start-SystemMonitor
    Starts monitoring using the default output location.

.EXAMPLE
    Start-SystemMonitor -OutPath "D:\Logs"
    Starts monitoring with a custom log file location.

.OUTPUTS
    Creates a log file named "SystemMonitor.txt" in the specified directory.

.NOTES
    Name: Start-SystemMonitor
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-01-31
#>
function Start-SystemMonitor {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$OutPath = "$env:HOMEDRIVE"
    )

    try {
        # Resolve the full path
        $OutPath = [System.IO.Path]::GetFullPath($OutPath)
        
        # Create directory if it doesn't exist
        if (-not (Test-Path -Path $OutPath -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $OutPath -Force
            Write-Verbose "Created directory: $OutPath"
        }

        # Define and create the output file
        $outputFile = Join-Path -Path $OutPath -ChildPath "SystemMonitor.txt"
        if (-not (Test-Path -Path $outputFile)) {
            $null = New-Item -ItemType File -Path $outputFile -Force
            Write-Verbose "Created log file: $outputFile"
        }

        # Test write access
        $testContent = "Testing write access..."
        Set-Content -Path $outputFile -Value $testContent -ErrorAction Stop
        Write-Verbose "Verified write access to log file"
    }
    catch {
        Write-Error "Failed to setup logging: $_"
        throw "Unable to create or access log file at: $outputFile"
    }

    # Registry paths to monitor
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    # List of processes to ignore
    $ignoreProcesses = @(
        'svchost',
        'RuntimeBroker',
        'backgroundTaskHost',
        'conhost',
        'WmiPrvSE'
    )

    # Helper function to write output
    function Write-OutputBoth {
        param(
            [string]$Message,
            [string]$ForegroundColor = 'White',
            [string]$Category = 'Process'
        )
        
        Write-Host "----------------------------------------" -ForegroundColor Blue
        Write-Host "-------------$Category-------------" -ForegroundColor Cyan
        Write-Host "----------------------------------------" -ForegroundColor Blue
        Write-Host $Message -ForegroundColor $ForegroundColor
        Write-Host "----------------------------------------" -ForegroundColor Blue
        
        try {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $outputFile -Value @(
                "----------------------------------------"
                "-------------$Category-------------"
                "----------------------------------------"
                $Message
                "----------------------------------------"
            )
        }
        catch {
            Write-Warning "Failed to write to log file: $_"
        }
    }

    # Function to get software list
    function Get-InstalledSoftware {
        $software = @()
        foreach ($path in $registryPaths) {
            $items = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName -and $_.UninstallString }

            foreach ($item in $items) {
                $GUID = $null
                if ($item.UninstallString -match "({[A-Z0-9-]+})") {
                    $GUID = $matches[1]
                }

                $software += [PSCustomObject]@{
                    DisplayName = $item.DisplayName
                    Version = $item.DisplayVersion
                    Architecture = if($path -like "*WOW6432Node*") {"32-bit"} else {"64-bit"}
                    GUID = $GUID
                    Publisher = $item.Publisher
                }
            }
        }
        return $software
    }

    # Initialize monitoring
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Set-Content -Path $outputFile -Value "System Monitoring Started at: $timestamp" -Force
        
        # Get initial states
        $initialProcesses = Get-Process | 
            Where-Object { $_.ProcessName -notin $ignoreProcesses } | 
            Select-Object Id, ProcessName, Path, StartTime

        $initialSoftware = Get-InstalledSoftware
        
        Write-Host "Monitoring processes and software changes... Press Ctrl+C to stop" -ForegroundColor Cyan
        Write-Host "Logging to: $outputFile" -ForegroundColor Cyan

        # Main monitoring loop
        while ($true) {
            # Monitor Processes
            $currentProcesses = Get-Process | 
                Where-Object { $_.ProcessName -notin $ignoreProcesses } | 
                Select-Object Id, ProcessName, Path, StartTime
            
            $processComparison = Compare-Object -ReferenceObject $initialProcesses -DifferenceObject $currentProcesses -Property Id
            
            # Handle new processes
            foreach ($process in ($processComparison | Where-Object { $_.SideIndicator -eq '=>' })) {
                $processDetails = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
                if ($processDetails) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $message = @"
New [+] '$($processDetails.ProcessName)'
Detection Time: $timestamp
Process Start: $($processDetails.StartTime)
Name: $($processDetails.ProcessName)
PID:  $($processDetails.Id)
Path: $($processDetails.Path)
"@
                    Write-OutputBoth -Message $message -ForegroundColor Green -Category 'Process'
                }
            }
            
            # Handle closed processes
            foreach ($process in ($processComparison | Where-Object { $_.SideIndicator -eq '<=' })) {
                $closedProcess = $initialProcesses | Where-Object { $_.Id -eq $process.Id }
                if ($closedProcess) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $message = @"
Closed [-] '$($closedProcess.ProcessName)'
Detection Time: $timestamp
Process Start: $($closedProcess.StartTime)
Process End: $timestamp
Name: $($closedProcess.ProcessName)
PID:  $($closedProcess.Id)
Path: $($closedProcess.Path)
"@
                    Write-OutputBoth -Message $message -ForegroundColor Yellow -Category 'Process'
                }
            }

            # Monitor Software Changes
            $currentSoftware = Get-InstalledSoftware
            $softwareComparison = Compare-Object -ReferenceObject $initialSoftware -DifferenceObject $currentSoftware -Property DisplayName
            
            # Handle new software
            foreach ($software in ($softwareComparison | Where-Object { $_.SideIndicator -eq '=>' })) {
                $newSoftware = $currentSoftware | Where-Object { $_.DisplayName -eq $software.DisplayName }
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $message = @"
====== Detection Information for: $($newSoftware.DisplayName) ======
Version: $($newSoftware.Version)
Architecture: $($newSoftware.Architecture)
Detection Time: $timestamp
Publisher: $($newSoftware.Publisher)
GUID: $($newSoftware.GUID)
"@
                Write-OutputBoth -Message $message -ForegroundColor Green -Category 'Software'
            }
            
            # Handle removed software
            foreach ($software in ($softwareComparison | Where-Object { $_.SideIndicator -eq '<=' })) {
                $removedSoftware = $initialSoftware | Where-Object { $_.DisplayName -eq $software.DisplayName }
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $message = @"
====== Detection Information for: $($removedSoftware.DisplayName) [REMOVED] ======
Version: $($removedSoftware.Version)
Architecture: $($removedSoftware.Architecture)
Detection Time: $timestamp
Publisher: $($removedSoftware.Publisher)
GUID: $($removedSoftware.GUID)
"@
                Write-OutputBoth -Message $message -ForegroundColor Yellow -Category 'Software'
            }
            
            # Update initial states
            $initialProcesses = $currentProcesses
            $initialSoftware = $currentSoftware
            
            Start-Sleep -Milliseconds 250
        }
    }
    catch {
        Write-Warning "Monitoring stopped: $_"
    }
    finally {
        Write-Host "`nMonitoring ended. Log file: $outputFile" -ForegroundColor Cyan
    }
}