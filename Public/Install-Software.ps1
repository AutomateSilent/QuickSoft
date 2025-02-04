<#
.SYNOPSIS
    Installs software from an EXE or MSI file.

.COMPONENT
    QuickSoft

.DESCRIPTION
    This function installs software from a specified EXE or MSI file. It automatically detects the file type and handles installation accordingly. For MSI files, it defaults to silent installation (/qn) unless custom arguments are provided. Supports logging to a file if specified.

.PARAMETER FilePath
    The full path to the EXE or MSI file to install.

.PARAMETER Arguments
    Optional arguments to pass to the installer. For MSI files, custom arguments override the default silent installation (/qn).

.PARAMETER Log
    Optional path to a log file. If provided, installation logs will be written to this file in addition to the console.

.EXAMPLE
    Install-Software -FilePath "C:\installer.exe"
    Installs the software from the specified EXE file.

.EXAMPLE
    Install-Software -FilePath "C:\package.msi" -Arguments "/qn /norestart"
    Installs the MSI package silently without restarting the system.

.EXAMPLE
    Install-Software -FilePath "C:\package.msi" -Log "C:\install.log"
    Installs the MSI package silently and logs the process to the specified file.

.OUTPUTS
    None. Writes installation progress and results to the console and optionally to a log file.

.NOTES
    Name: Install-Software
    Author: AutomateSilent
    Version: 1.0.1
    Last Updated: 2025-02-04
#>
function Install-Software {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The full path to the EXE or MSI file to install."
        )]
        [ValidateScript({ Test-Path $_ })]
        [string]$FilePath,

        [Parameter(
            Position = 1,
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Optional arguments to pass to the installer."
        )]
        [string]$Arguments,

        [Parameter(
            Position = 2,
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Optional path to a log file."
        )]
        [string]$Log
    )

    begin {
        function Write-InstallLog {
            param($Message)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logMessage = "[$timestamp] $Message"
            if ($Log) { Add-Content -Path $Log -Value $logMessage }
            Write-Host $logMessage
        }

        try {
            # Convert to absolute path to avoid any path-related issues
            $FilePath = (Resolve-Path $FilePath).Path
            Write-Verbose "Initializing installation process for $FilePath"
        }
        catch {
            Write-Error "Initialization failed: $_"
            return
        }
    }

    process {
        try {
            $extension = [System.IO.Path]::GetExtension($FilePath).TrimStart('.').ToLower()
            if ($extension -notin 'exe', 'msi') {
                Write-InstallLog "ERROR: Unsupported file type '$extension'. Only EXE and MSI are supported."
                return
            }

            Write-InstallLog "Starting installation: $FilePath"

            if ($extension -eq 'exe') {
                $params = @{
                    FilePath = $FilePath
                    Wait = $true
                    PassThru = $true
                    Verb = 'RunAs'  # Ensures elevated privileges
                }
                if ($Arguments) { $params.ArgumentList = $Arguments }
                $process = Start-Process @params
            }
            else {
                # Default MSI arguments (silent install)
                $msiArgs = if ($Arguments) {
                    Write-InstallLog "Using custom MSI arguments: $Arguments"
                    "/i `"$FilePath`" $Arguments"
                }
                else {
                    Write-InstallLog "Using default MSI arguments: /i `"$FilePath`" /qn"
                    "/i `"$FilePath`" /qn"
                }
                
                # Use full path to msiexec and run with proper verb
                $process = Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -Verb RunAs
            }

            Write-InstallLog "Exit code: $($process.ExitCode). $(if ($process.ExitCode -ne 0) {'Installation failed!'} else {'Success!'})"
        }
        catch {
            Write-InstallLog "ERROR: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Installation process completed for $FilePath"
    }
}