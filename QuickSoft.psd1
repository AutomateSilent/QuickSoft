@{
    RootModule = 'QuickSoft.psm1'
    ModuleVersion = '1.1.2'
    GUID = 'f1b27db4-5c57-4848-9e19-1537fc079e74'
    Author = 'AutomateSilent'
    CompanyName = 'AutomateSilent'
    Copyright = '(c) 2025 AutomateSilent. All rights reserved.'
    Description = 'Comprehensive software management and system monitoring tools'
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
        'New-WinRarSFX'
    )
    CmdletsToExport = @()
    VariablesToExport = @() 
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Software', 'Management', 'Monitoring', 'MSI', 'System', 'Theme', 'Windows', 'Automation', 'WinRAR', 'SFX', 'Installation')
            LicenseUri = 'https://github.com/AutomateSilent/QuickSoft/blob/main/LICENSE'
            ProjectUri = 'https://github.com/AutomateSilent/QuickSoft'
            ReleaseNotes = @'
# QuickSoft Module v1.1.2

## New Feature 🚀
* New-WinRarSFX - Create self-extracting archives
  - Automatic PowerShell script detection
  - Silent operation & batch processing support
  - Configurable extraction paths
  - Custom setup commands

## Improvements 🔨
* Enhanced Install-Software
  - Fixed UNC path resolution (errors 1603/1619)
  - Added PowerShell provider prefix support
  - Improved network path compatibility

## Core Features ⚡
* Software Management
  - Complete software management
  - Automated deployment tools
  - IT Admin tools
* PowerShell Environment
  - ISE dark theme customization
  - Enhanced logging capabilities
  - Robust error handling

For full details visit: https://github.com/AutomateSilent/QuickSoft
'@
        }
    }
}