<#
.SYNOPSIS
    Gets the product code from an MSI file.

.COMPONENT
    QuickSoft

.DESCRIPTION
    Extracts the product code GUID from a specified MSI file using the Windows Installer object model.
    This can be useful for software detection and uninstallation.

.PARAMETER MsiPath
    The full path to the MSI file to analyze.

.EXAMPLE
    Get-MSIProductCode -MsiPath "C:\Downloads\setup.msi"
    Returns the product code GUID from the specified MSI file.

.OUTPUTS
    System.String
    Returns the product code GUID from the MSI file.

.NOTES
    Name: Get-MSIProductCode
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-01-31
#>
function Get-MSIProductCode {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to the MSI file"
        )]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$MsiPath
    )

    try {
        $installer = New-Object -ComObject WindowsInstaller.Installer
        $database = $installer.GetType().InvokeMember(
            "OpenDatabase", 
            "InvokeMethod", 
            $null, 
            $installer, 
            @($MsiPath, 0)
        )

        $view = $database.GetType().InvokeMember(
            "OpenView",
            "InvokeMethod",
            $null,
            $database,
            @("SELECT * FROM Property WHERE Property = 'ProductCode'")
        )

        $view.GetType().InvokeMember("Execute", "InvokeMethod", $null, $view, $null)
        $record = $view.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $view, $null)
        $productCode = $record.GetType().InvokeMember("StringData", "GetProperty", $null, $record, 2)

        $view.GetType().InvokeMember("Close", "InvokeMethod", $null, $view, $null)
        
        return $productCode
    }
    catch {
        Write-Error "Error retrieving product code from MSI: $_"
        return $null
    }
}