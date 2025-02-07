# Changelog
All notable changes to QuickSoft will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> Note: Version numbering jumped from 1.0.0 to 1.0.2 to maintain consistency between PSGallery and GitHub repositories due to initial source file upload discrepancies.

## [1.1.2] - 2025-02-06
### Added
- New cmdlet `New-WinRarSFX` for creating self-extracting archives:
  - Automatic PowerShell script detection and execution
  - Flexible naming options with multiple fallback strategies
  - Configurable extraction paths and post-extraction commands
  - Silent operation support with customizable interface visibility
  - Comprehensive error handling and path validation
  - Pipeline support for batch processing

### Changed
- Enhanced path resolution logic to handle both local and UNC paths more robustly
- Improved current location detection by using `ProviderPath` instead of `Path`

### Fixed
- Resolved installation failures (errors 1603/1619) when executing from UNC paths
- Added handling of PowerShell provider prefix (`Microsoft.PowerShell.Core\FileSystem::`) in file paths
- Implemented proper cleanup of redundant backslashes while preserving UNC path format
- Fixed path resolution when running script directly from network locations

### Security
- Maintained proper path sanitization for UNC paths to prevent path manipulation issues

## [1.0.2] - 2025-02-04
### Fixed
- Install-Software: Resolved MSI error 1619 by implementing proper system elevation and path handling
- Added elevation requirement checks for SFX creation to ensure proper permissions

## [1.0.0] - 2025-02-03
### Added
- Initial release of QuickSoft module
- Full documentation and help for all functions
- MIT License
- GitHub Actions for automated testing
- Pester test framework integration

### Security
- Initial security policy and vulnerability reporting process
- Safe error handling in all functions

## [1.0.0] - 2025-01-31
### Added
- Initial creation of QuickSoft module
- Get-Software for software inventory management
- Manage-Software for interactive software management
- Get-MSIProductCode for extracting MSI product codes
- Get-SoftwareDetectionMethod for generating deployment detection rules
- Get-SoftwareDetectionMethod2 for alternative detection methods
- Set-ISEDarkTheme for PowerShell ISE customization
- Start-SystemMonitor for system and software change monitoring
- Install-Software for EXE and MSI installation
