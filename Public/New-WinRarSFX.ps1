<#
.SYNOPSIS
    Creates a self-extracting archive (SFX) from a directory with configurable installation options.

.DESCRIPTION
    Creates a self-extracting (SFX) archive using WinRAR, with required extraction path, optional 
    post-extraction command. Automatically handles PowerShell script
    detection and execution, with flexible naming options.

    The function follows this priority for output naming:
    1. User-specified OutPutExe name extension (ex: "Custom_Tool_Name.exe")
    3. Title parameter (with spaces converted to underscores)
    2. Uses detected PowerShell script name
    4. Source directory name as final fallback

.PARAMETER FilePath
    Path to the directory that will be compressed into the SFX archive.

.PARAMETER OutputExe
    Path where the SFX executable will be created.

.PARAMETER WinRarPath
    Path to WinRAR installation directory. Defaults to "C:\Program Files\WinRAR".
    Will attempt to find WinRAR in common installation paths if not found at default location.

.PARAMETER ExtractionPath
    Target path where files will be extracted. 
    Defaults to "C:\Windows\Temp\{Title}".

.PARAMETER SetupCommand
    Command to execute after extraction. Supports:
    - "Script" - Auto-detects and executes a PowerShell script (recommended for .ps1 files)
    - Custom command (e.g., "notepad.exe config.txt")
    - Skip post-extraction execution by omitting this parameter

.PARAMETER Title
    Custom title for the SFX and default exe name (spaces converted to underscores for filename).
    If not specified, uses:
    1. Detected PowerShell script name (without extension)
    2. Source directory name as fallback

.PARAMETER Overwrite
    Controls file overwrite behavior:
    0 = Prompt user
    1 = Overwrite silently (default)
    2 = Skip existing files

.PARAMETER Silent
    Controls interface visibility:
    0 = Show all dialogs and progress
    1 = Silent operation (default)
    2 = Show only errors

.EXAMPLE
    New-WinRarSFX -FilePath "C:\Scripts\Tool" -SetupCommand "Script"

    # Pipeline input for FilePath
    "C:\Scripts\Tool" | New-WinRarSFX -SetupCommand "Script"
    
    Basic usage that auto-detects a PowerShell script. Uses .Ps1 file name,
    creates "Your_File_Name.exe" that runs the script after extraction.

.EXAMPLE
    New-WinRarSFX -FilePath "C:\Config\App" -SetupCommand "cmd.exe /c start config.exe"
    
    Creates an SFX that runs a custom command.
    Useful for non-PowerShell deployments.

.EXAMPLE
    New-WinRarSFX -FilePath "C:\Scripts\Tool" -Title "Custom_Tool_Name" -SetupCommand "Script"

    Creates an SFX with a specific name regardless of the script name or source directory.
    Useful when you need consistent naming across different deployments.

.EXAMPLE
    $params = @{
        FilePath = "C:\Scripts\Tool"
        OutputExe = "C:\Scripts\Tool\CustomDeployment.exe"
        ExtractionPath = "C:\Windows\Temp\Tool"
        SetupCommand = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"C:\Windows\Temp\GPUninstall\Install.ps1`""
        Title = "Custom Title"
        Silent = 1
        Overwrite = 1
        Verbose = $true
    }
    New-WinRarSFX @params
    
    Advanced usage with full parameter control.

.EXAMPLE
    # Process multiple script directories for deployment
    Get-ChildItem -Path "C:\DeploymentScripts" -Directory | New-WinRarSFX -SetupCommand "Script"
    
    Creates an SFX for each subdirectory in DeploymentScripts, auto-detecting PowerShell scripts.
    Useful for batch processing multiple deployment packages.

.NOTES
    Name: New-WinRarSFX
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-02-06
    
    Requires WinRAR to be installed on the system.
    Automatically handles spaces in paths and file names.
    Best used with PowerShell scripts using the "Script" template.
#>

function New-WinRarSFX {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to the directory that will be compressed into the SFX archive"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,
        
        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path where the SFX executable will be created"
        )]
        [string]$OutputExe,
        
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to WinRAR installation directory"
        )]
        [string]$WinRarPath = "C:\Program Files\WinRAR",
        
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Target path where files will be extracted"
        )]
        [string]$ExtractionPath,
        
        [Parameter(
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Command to execute after extraction. Use 'Script' for automatic PowerShell script detection"
        )]
        [string]$SetupCommand,
        
        [Parameter(
            Position = 3,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Custom title for the SFX and default exe name (spaces converted to underscores)"
        )]
        [string]$Title,
        
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Controls file overwrite behavior (0=Prompt, 1=Overwrite, 2=Skip)"
        )]
        [ValidateRange(0, 2)]
        [int]$Overwrite = 1,
        
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Controls interface visibility (0=Show all, 1=Silent, 2=Show errors)"
        )]
        [ValidateRange(0, 2)]
        [int]$Silent = 1
    )

    begin {
        Write-Verbose "Checking elevation status..."
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal $identity
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "This function requires elevated privileges. Please run PowerShell as Administrator."
        }

        Write-Verbose "Initializing SFX creation process..."
        
        # Check WinRAR installation first
        $alternativePaths = @(
            $WinRarPath,
            "${env:ProgramFiles}\WinRAR",
            "${env:ProgramFiles(x86)}\WinRAR"
        )
        
        $validPath = $null
        foreach ($path in $alternativePaths) {
            if (Test-Path $path) {
                $validPath = $path
                break
            }
        }
        
        if (-not $validPath) {
            Write-Host "`nWinRAR not found in standard locations." -ForegroundColor Yellow
            Write-Host "Download WinRAR from: https://www.win-rar.com/download.html?&L=0" -ForegroundColor Cyan
            Write-Host "After installing WinRAR, you can continue with the installation.`n" -ForegroundColor Yellow
            
            do {
                $customPath = Read-Host "Please specify WinRAR installation path (or 'Q' to quit)"
                
                if ($customPath -eq 'Q') {
                    throw "Operation cancelled by user"
                }
                
                if (Test-Path $customPath) {
                    $validPath = $customPath
                    break
                } else {
                    Write-Warning "Invalid path. Please try again."
                }
            } while (-not $validPath)
        }
        
        $WinRarPath = $validPath
        Write-Verbose "Using WinRAR from: $WinRarPath"
        
        # Now validate source path
        try {
            $FilePath = [System.IO.Path]::GetFullPath($FilePath)
        } catch {
            throw "Invalid file path format: $FilePath"
        }
        
        if (-not (Test-Path $FilePath)) {
            do {
                Write-Warning "Source path not found: $FilePath"
                $newPath = Read-Host "Please specify a valid source path (or 'Q' to quit)"
                
                if ($newPath -eq 'Q') {
                    throw "Operation cancelled by user"
                }
                
                if (Test-Path $newPath) {
                    $FilePath = [System.IO.Path]::GetFullPath($newPath)
                    break
                } else {
                    Write-Warning "Invalid path. Please try again."
                }
            } while ($true)
        }

        # If Title isn't specified, try to use setup script name, then fall back to directory name
        if (-not $Title) {
            $psScript = Get-ChildItem -Path $FilePath -Filter "*.ps1" | Select-Object -First 1
            if ($psScript) {
                $Title = [System.IO.Path]::GetFileNameWithoutExtension($psScript.Name)
            } else {
                $Title = (Split-Path -Leaf $FilePath)
            }
        }
        
        # Set default extraction path
        if (-not $ExtractionPath) {
            $ExtractionPath = "C:\Windows\Temp\$Title"
        }
        
        # Set OutputExe based on Title if not explicitly specified
        if (-not $OutputExe) {
            $exeName = $Title -replace '\s+', '_'
            $OutputExe = Join-Path $FilePath "$exeName.exe"
        }
        
        # Ensure output directory exists
        $outputDir = Split-Path -Parent $OutputExe
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
    }

    process {
        try {
            Write-Verbose "Creating temporary workspace..."
            $workDir = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
            New-Item -ItemType Directory -Path $workDir -Force | Out-Null

            # Handle SetupCommand processing
            $finalSetupCommand = ""
            if ($SetupCommand) {
                if ($SetupCommand -eq "Script") {
                    Write-Verbose "Detecting PowerShell scripts in source directory..."
                    $psScripts = Get-ChildItem -Path $FilePath -Filter "*.ps1"
                    
                    if ($psScripts.Count -eq 0) {
                        throw "No PowerShell scripts found in source directory"
                    } elseif ($psScripts.Count -eq 1) {
                        $scriptName = $psScripts[0].Name
                        $finalSetupCommand = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ExtractionPath\$scriptName`""
                    } else {
                        Write-Host "`nMultiple PowerShell scripts found:"
                        for ($i = 0; $i -lt $psScripts.Count; $i++) {
                            Write-Host "$($i + 1). $($psScripts[$i].Name)" -ForegroundColor Cyan
                        }
                        
                        $selection = Read-Host "`nSelect script number"
                        if ($selection -match '^\d+$' -and [int]$selection -le $psScripts.Count) {
                            $scriptName = $psScripts[[int]$selection - 1].Name
                            $finalSetupCommand = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ExtractionPath\$scriptName`""
                        } else {
                            throw "Invalid script selection"
                        }
                    }
                } else {
                    $finalSetupCommand = $SetupCommand
                }
            }

            # Generate SFX configuration
            Write-Verbose "Generating SFX configuration..."
            $configContent = @"
;The comment below contains SFX script commands
Path="$ExtractionPath"
"@
            
            if ($finalSetupCommand) {
                $configContent += "`nSetup=$finalSetupCommand"
            }
            
            $configContent += @"

Overwrite=$Overwrite
Silent=$Silent
Title="$Title"
"@

            $configPath = Join-Path $workDir "config.txt"
            [System.IO.File]::WriteAllText($configPath, $configContent, [System.Text.Encoding]::ASCII)

            # Select appropriate SFX module
            Write-Verbose "Selecting SFX module..."
            $sfxModule = Join-Path $WinRarPath "Default.SFX"
            if (-not (Test-Path $sfxModule)) {
                $sfxModule = Join-Path $WinRarPath "WinCon.SFX"
                if (-not (Test-Path $sfxModule)) {
                    throw "No suitable SFX module found in WinRAR directory"
                }
            }

            # Build WinRAR command
            Write-Verbose "Building WinRAR command..."
            $winrarExe = Join-Path $WinRarPath "WinRAR.exe"
            $startInfo = New-Object System.Diagnostics.ProcessStartInfo
            $startInfo.FileName = $winrarExe
            $startInfo.Arguments = "a -cfg- -ep1 -inul -iadm -m5 -r -s `"-sfx$sfxModule`" -y `"-z$configPath`" `"$OutputExe`" `"$FilePath\*`""
            $startInfo.UseShellExecute = $false
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.CreateNoWindow = $true

            # Execute WinRAR process
            Write-Verbose "Executing WinRAR command..."
            $process = Start-Process -FilePath $startInfo.FileName -ArgumentList $startInfo.Arguments -NoNewWindow -Wait -PassThru

            if ($process.ExitCode -ne 0) {
                throw "WinRAR process failed with exit code: $($process.ExitCode)"
            }

            # Verify output file
            if (Test-Path $OutputExe) {
                Write-Host "SFX archive created successfully:" -ForegroundColor Green
                Write-Host "Location: $OutputExe" -ForegroundColor Cyan
                Write-Host "Size: $([math]::Round((Get-Item $OutputExe).Length / 1MB, 2)) MB" -ForegroundColor Cyan
            } else {
                throw "SFX creation failed - output file not found"
            }
        }
        catch {
            Write-Error "Failed to create SFX: $_"
            throw
        }
        finally {
            # Cleanup
            if (Test-Path $workDir) {
                Remove-Item -Path $workDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    end {
        Write-Verbose "SFX creation process completed"
    }
}