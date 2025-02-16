@{
    RootModule = 'QuickSoft.psm1'
    ModuleVersion = '1.2.2'
    GUID = 'f1b27db4-5c57-4848-9e19-1537fc079e74'
    Author = 'AutomateSilent'
    CompanyName = 'AutomateSilent'
    Copyright = '(c) 2025 AutomateSilent. All rights reserved.'
    Description = 'PowerShell toolkit for software packaging, path management, and system utilities. Features WinRAR SFX creation, quick directory navigation, and software install, detection, and uninstall functions.'   
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Start-SoftwareManagement',
        'Start-SystemMonitor',
        'Get-MSIProductCode',
        'Get-Software',
        'Get-SoftwareDetectionMethod',
        'Get-SoftwareDetectionMethod2',
        'Set-ISEDarkTheme',
        'Install-Software',
        'New-WinRarSFX',
        'Start-QuickPaths', 
        'qp',
        'Show-QuickSoftBanner'
    )
    CmdletsToExport = @()
    VariablesToExport = @('QuickPathsFile') 
    AliasesToExport = @('q')
    PrivateData = @{
        PSData = @{
            Tags = @('Software', 'Management', 'Monitoring', 'MSI', 'System', 'Theme', 'Windows', 'Automation', 'WinRAR', 'SFX', 'Installation')
            LicenseUri = 'https://github.com/AutomateSilent/QuickSoft/blob/main/LICENSE'
            ProjectUri = 'https://github.com/AutomateSilent/QuickSoft'
            ReleaseNotes = @'
QuickSoft Module v1.2.2

New Feature 
* Start-QuickPath - Enhanced directory navigation system
  - Fast directory switching with aliases
  - Persistent path configurations
  - Tab completion support
  - Profile integration
  - Multiple user scope support

Core Features 
* Software Utilities
  - WinRAR SFX packaging
  - Software detection and management
  - MSI product code retrieval
* PowerShell Enhancements
  - ISE dark theme
  - Quick access utilities
  - Profile customization

For full details visit: https://github.com/AutomateSilent/QuickSoft
'@
        }
    }
}