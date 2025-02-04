<#
.SYNOPSIS
    Retrieves installed software information from the Windows registry.
    
.COMPONENT
    QuickSoft

.DESCRIPTION
    Gets detailed information about installed software from both 32-bit and 64-bit registry locations.
    Provides comprehensive details including installation paths, versions, and uninstall strings.
    Supports wildcard searches for software names.

.PARAMETER DisplayName
    The name of the software to search for. Supports wildcards (*).
    Default value is "*" which returns all installed software.

.EXAMPLE
    Get-Software -DisplayName "Google Chrome"
    Returns detailed information about the Google Chrome installation.

.EXAMPLE
    Get-Software -DisplayName "Microsoft*"
    Returns information about all installed Microsoft software.

.EXAMPLE
    Get-Software
    Returns information about all installed software.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns objects containing software details including:
    - DisplayName
    - Publisher
    - Bit (32-bit or 64-bit)
    - GUID
    - Version
    - UninstallString
    - InstallDate

.NOTES
    Name: Get-Software
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-01-31
#>
function Get-Software {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Name of the software to search for (supports wildcards)"
        )]
        [SupportsWildcards()]
        [string]$DisplayName = "*"
    )

    begin {
        $uninstallKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
    }

    process {
        $results = @()

        foreach ($key in $uninstallKeys) {
            $items = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | 
                     Where-Object { $_.DisplayName -like $DisplayName -and $_.UninstallString }

            foreach ($item in $items) {
                $GUID = $null
                if ($item.UninstallString -match "({[A-Z0-9-]+})") {
                    $GUID = $matches[1]
                }

                $formattedDate = if ($item.InstallDate) {
                    try {
                        [DateTime]::ParseExact($item.InstallDate, "yyyyMMdd", $null).ToString("MMM dd, yyyy")
                    }
                    catch {
                        $item.InstallDate  # Return original if parsing fails
                    }
                } else {
                    "Not Available"
                }

                $results += [PSCustomObject]@{
                    DisplayName = $item.DisplayName
                    Publisher = $item.Publisher
                    Bit = if($key -like "*Wow6432Node*") {"32-bit"} else {"64-bit"}
                    GUID = $GUID
                    Version = $item.DisplayVersion
                    UninstallString = $item.UninstallString
                    InstallDate = $formattedDate
                }
            }
        }

        foreach ($result in $results) {
            Write-Host "----------------------------------------" -ForegroundColor Magenta
            Write-Host "DisplayName: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.DisplayName)" -ForegroundColor Green
            Write-Host "Publisher: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.Publisher)" -ForegroundColor White
            Write-Host "Bit: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.Bit)" -ForegroundColor White
            Write-Host "GUID: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.GUID)" -ForegroundColor White
            Write-Host "Version: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.Version)" -ForegroundColor White
            Write-Host "UninstallString: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.UninstallString)" -ForegroundColor White
            Write-Host "InstallDate: " -ForegroundColor Cyan -NoNewline; Write-Host "$($result.InstallDate)" -ForegroundColor White
        }
    }
}