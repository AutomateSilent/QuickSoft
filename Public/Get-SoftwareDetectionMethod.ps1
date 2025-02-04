<#
.SYNOPSIS
    Generates software detection methods for deployment tools.

.COMPONENT
    QuickSoft
        
.DESCRIPTION
    Searches for software in the Windows registry and provides detection method recommendations
    suitable for deployment tools like Microsoft Intune. Analyzes both standard and vendor-specific
    registry paths to determine the most reliable detection method.

.PARAMETER DisplayName
    The name of the software to analyze. Supports wildcards (*).

.EXAMPLE
    Get-SoftwareDetectionMethod -DisplayName "Adobe Reader"
    Returns detection methods for Adobe Reader installation.

.EXAMPLE
    Get-SoftwareDetectionMethod -DisplayName "Microsoft*"
    Returns detection methods for all Microsoft software.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns objects containing detection information including registry paths and values.

.NOTES
    Name: Get-SoftwareDetectionMethod
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-01-31
#>
function Get-SoftwareDetectionMethod {
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
        "HKLM:\SOFTWARE",
        "HKLM:\SOFTWARE\Wow6432Node"
    )

    $results = @()

    foreach ($key in $uninstallKeys) {
        $items = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | 
                 Where-Object { $_.DisplayName -like $DisplayName }

        foreach ($item in $items) {
            $itemPath = $item.PSPath -replace "Microsoft.PowerShell.Core\\Registry::", ""
            $poshPath = $itemPath -replace "HKEY_LOCAL_MACHINE\\", "HKLM:\"
            
            $pathExists = Test-Path $poshPath
            
            $properties = if ($pathExists) {
                Get-ItemProperty -Path $poshPath -ErrorAction SilentlyContinue
            } else { $null }

            $vendorPath = $null
            foreach ($basePath in $commonRegPaths) {
                $searchPath = Join-Path $basePath "*$($item.DisplayName)*"
                $vendorKeys = Get-Item -Path $searchPath -ErrorAction SilentlyContinue
                if ($vendorKeys) {
                    $vendorPath = $vendorKeys.PSPath -replace "Microsoft.PowerShell.Core\\Registry::", ""
                    break
                }
            }

            $results += [PSCustomObject]@{
                DisplayName = $item.DisplayName
                Version = $item.DisplayVersion
                Architecture = if($key -like "*WOW6432Node*") {"32-bit"} else {"64-bit"}
                MainRegPath = $itemPath
                MainRegPathExists = $pathExists
                VendorRegPath = $vendorPath
                VendorRegPathExists = if($vendorPath) { Test-Path ($vendorPath -replace "HKEY_LOCAL_MACHINE\\", "HKLM:\") } else { $false }
                Properties = $properties
            }
        }
    }

    if ($results.Count -gt 0) {
        foreach ($result in $results) {
            Write-Host "`n====== Detection Information for: $($result.DisplayName) ======" -ForegroundColor Green
            Write-Host "Version: $($result.Version)" -ForegroundColor Yellow
            Write-Host "Architecture: $($result.Architecture)" -ForegroundColor Yellow
            
            Write-Host "`nMain Registry Path:" -ForegroundColor Cyan
            Write-Host "Path: $($result.MainRegPath)"
            Write-Host "Path Exists: $($result.MainRegPathExists)"
            
            if ($result.Properties) {
                Write-Host "`nAvailable Registry Values:" -ForegroundColor Magenta
                $result.Properties.PSObject.Properties | 
                    Where-Object { $_.Name -notlike "PS*" -and $_.Value } | 
                    Select-Object Name, Value | 
                    Format-Table -AutoSize
            }

            if ($result.VendorRegPath) {
                Write-Host "`nVendor-Specific Registry Path:" -ForegroundColor Cyan
                Write-Host "Path: $($result.VendorRegPath)"
                Write-Host "Path Exists: $($result.VendorRegPathExists)"
            }

            Write-Host "`nRecommended Intune Detection:" -ForegroundColor Green
            Write-Host "Note: Use HKEY_LOCAL_MACHINE format for Intune, HKLM: format for PowerShell testing" -ForegroundColor Yellow
            if ($result.VendorRegPathExists) {
                Write-Host "Use Vendor Registry Path:"
                Write-Host "Path: $($result.VendorRegPath)"
                Write-Host "Rule type: Registry"
                Write-Host "Detection method: Key exists"
            } else {
                Write-Host "Use Main Registry Path:"
                Write-Host "Path: $($result.MainRegPath)"
                Write-Host "Rule type: Registry"
                Write-Host "Detection method: Value exists"
                Write-Host "Suggested value name: DisplayName or DisplayVersion"
            }
        }
    }
    else {
        Write-Host "No software matching '$DisplayName' found." -ForegroundColor Red
    }

    return $results
}