<#
.SYNOPSIS
    QuickSoft PowerShell Module
.DESCRIPTION
    A comprehensive module for software management, detection, and system monitoring.
    Includes tools for software inventory, uninstallation, MSI management, and system monitoring.
.NOTES
    Module Name: QuickSoft
    Author: AutomateSilent
    Version: 1.0.2
    Last Updated: 2025-02-04
#>

# Get all public function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($import in $Public) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.BaseName