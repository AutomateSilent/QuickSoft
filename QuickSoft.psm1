<#
.SYNOPSIS
    QuickSoft PowerShell Module

.DESCRIPTION
    PowerShell toolkit for software packaging, path management, and system utilities.
    Features WinRAR SFX creation, quick directory navigation, and software install, detection, and uninstall functions.  

.NOTES
    Module Name: QuickSoft
    Author: AutomateSilent
    Version: 1.2.2
    Last Updated: 2025-07-04
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