<#
.SYNOPSIS
    Alternative method for generating software detection rules.

.COMPONENT
    QuickSoft    

.DESCRIPTION
    Provides an alternative approach to generating software detection methods,
    focusing on GUID-based detection and additional registry paths.
    This function is particularly useful for MSI-based installations.

.PARAMETER DisplayName
    The name of the software to analyze. Supports wildcards (*).

.EXAMPLE
    Get-SoftwareDetectionMethod2 -DisplayName "Adobe Reader"
    Returns alternative detection methods for Adobe Reader installation.

.EXAMPLE
    Get-SoftwareDetectionMethod2 -DisplayName "Microsoft*"
    Returns alternative detection methods for all Microsoft software.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns objects containing detection information including GUIDs and registry paths.

.NOTES
    Name: Get-SoftwareDetectionMethod2
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-01-31
#>
function Get-SoftwareDetectionMethod2 {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Name of the software to analyze (supports wildcards)"
        )]
        [SupportsWildcards()]
        [string]$DisplayName = "*"
    )

    $uninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $commonRegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE",
        "HKLM:\SOFTWARE\Wow6432Node"
    )

    $results = @()

    foreach ($key in $uninstallKeys) {
        $items = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | 
                 Where-Object { $_.DisplayName -like $DisplayName -and $_.UninstallString }

        foreach ($item in $items) {
            $GUID = $null
            $registryPath = $null
            $registryValue = $null
            $version = $item.DisplayVersion
            
            if ($item.UninstallString -match "({[A-Z0-9-]+})") {
                $GUID = $matches[1]
            }

            if (-not $GUID) {
                $itemPath = $item.PSPath -replace "Microsoft.PowerShell.Core\\Registry::", ""
                $registryPath = $itemPath
                
                $properties = Get-ItemProperty -Path $itemPath -ErrorAction SilentlyContinue
                $potentialValues = @(
                    @{ Name = "DisplayName"; Value = $properties.DisplayName },
                    @{ Name = "InstallLocation"; Value = $properties.InstallLocation },
                    @{ Name = "DisplayVersion"; Value = $properties.DisplayVersion },
                    @{ Name = "Publisher"; Value = $properties.Publisher }
                )

                foreach ($prop in $potentialValues) {
                    if ($prop.Value) {
                        $registryValue = @{
                            Name = $prop.Name
                            Value = $prop.Value
                        }
                        break
                    }
                }
            }

            $additionalPaths = @()
            foreach ($basePath in $commonRegPaths) {
                $searchPath = Join-Path $basePath "*$($item.DisplayName)*"
                $additionalKeys = Get-Item -Path $searchPath -ErrorAction SilentlyContinue
                if ($additionalKeys) {
                    $additionalPaths += $additionalKeys.PSPath -replace "Microsoft.PowerShell.Core\\Registry::", ""
                }
            }

            $results += [PSCustomObject]@{
                DisplayName = $item.DisplayName
                Version = $version
                Architecture = if($key -like "*WOW6432Node*") {"32-bit"} else {"64-bit"}
                GUID = $GUID
                RegistryPath = $registryPath
                RegistryValue = if ($registryValue) { "$($registryValue.Name)=$($registryValue.Value)" } else { $null }
                AdditionalPaths = $additionalPaths
            }
        }
    }

    if ($results.Count -gt 0) {
        foreach ($result in $results) {
            Write-Host "`n====== Detection Information for: $($result.DisplayName) ======" -ForegroundColor Green
            Write-Host "Version: $($result.Version)" -ForegroundColor Yellow
            Write-Host "Architecture: $($result.Architecture)" -ForegroundColor Yellow
            
            if ($result.GUID) {
                Write-Host "`nRecommended Detection Method (GUID):" -ForegroundColor Cyan
                Write-Host "Registry detection rule:"
                Write-Host "Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($result.GUID)"
                Write-Host "Value: DisplayName"
                Write-Host "Check existence: Yes"
            }
            else {
                Write-Host "`nAlternative Registry Detection Method:" -ForegroundColor Cyan
                Write-Host "Path: $($result.RegistryPath -replace 'HKLM:\\', 'HKEY_LOCAL_MACHINE\')"
                Write-Host "Value: $($result.RegistryValue)"
                Write-Host "Check existence: Yes"
                
                if ($result.AdditionalPaths) {
                    Write-Host "`nAdditional Potential Registry Paths:" -ForegroundColor Magenta
                    foreach ($path in $result.AdditionalPaths) {
                        Write-Host $path
                    }
                }
            }
        }
    }
    else {
        Write-Host "No software matching '$DisplayName' found." -ForegroundColor Red
    }

    return $results
}