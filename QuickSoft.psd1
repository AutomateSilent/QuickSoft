@{
    RootModule = 'QuickSoft.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'f1b27db4-5c57-4848-9e19-1537fc079e74'
    Author = 'AutomateSilent'
    CompanyName = 'AutomateSilent'    # Added this to match author
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
        'Install-Software'
    )
    CmdletsToExport = @()
    VariablesToExport = @() 
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Software', 'Management', 'Monitoring', 'MSI', 'System', 'Theme', 'Windows', 'Automation')  # Added a couple relevant tags
            LicenseUri = 'https://github.com/AutomateSilent/QuickSoft/blob/main/LICENSE'
            ProjectUri = 'https://github.com/AutomateSilent/QuickSoft'
            ReleaseNotes = 'Initial release of QuickSoft module.'
        }
    }
}