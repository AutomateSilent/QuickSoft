# 🚀 QuickSoft PowerShell Module

![Test PowerShell Module](https://github.com/AutomateSilent/QuickSoft/workflows/Test%20PowerShell%20Module/badge.svg)
[![PSGallery Version](https://img.shields.io/powershellgallery/v/QuickSoft?style=flat-square&logo=powershell&label=PSGallery&color=blue)](https://www.powershellgallery.com/packages/QuickSoft)
[![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/QuickSoft.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)](https://www.powershellgallery.com/packages/QuickSoft)
[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1-blue?style=flat&logo=powershell)](https://www.powershellgallery.com/packages/QuickSoft)
[![PSGallery Platform](https://img.shields.io/powershellgallery/p/PSWindowsUpdate.svg?style=flat&logo=powershell&label=PSGallery%20Platform)](https://www.powershellgallery.com/packages/QuickSoft)
![QuickSoft Logo](https://github.com/user-attachments/assets/c65679b4-c5cb-4b80-b807-aa6bcb796a06)
## 📖 Overview
QuickSoft is a robust PowerShell module designed for streamlined software management and system monitoring. Built with automation in mind, it simplifies software inventory, deployment, detection, and system monitoring tasks.

## ✨ Key Features
- 📦 Software Management (inventory, installation, uninstallation)
- 🔍 MSI Package Analysis and Detection
- 🎯 Deployment Tools and Detection Methods
- 📊 Real-time System Monitoring
- 🛠️ Administrative Utilities

## 🔧 Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges for some functions
- Windows operating system

## ⚡ Quick Installation

### PowerShell Gallery (Recommended) 
[![PSGallery Version](https://img.shields.io/powershellgallery/v/QuickSoft?style=flat-square&logo=powershell&label=PSGallery&color=blue)](https://www.powershellgallery.com/packages/QuickSoft)
```powershell
# Install from PSGallery (Recommended)
Install-Module -Name QuickSoft

# Import and verify
Import-Module QuickSoft
Get-Command -Module QuickSoft
```

### Manual Installation
1. Download and extract the module [Lattest Release](https://github.com/AutomateSilent/QuickSoft/releases)
3. Place in one of these locations:
   
   ```powershell
   # Current User
   $env:USERPROFILE\Documents\WindowsPowerShell\Modules\QuickSoft

   # All Users (Requires Admin)
   $env:ProgramFiles\WindowsPowerShell\Modules\QuickSoft
   ```
5. Import and verify:
   
   ```powershell
   Import-Module QuickSoft
   Get-Command -Module QuickSoft
   ```

## 📚 Getting Started
```powershell
# List available commands
Get-Command -Module QuickSoft

# View commands by category
Get-Command -Module QuickSoft | Group-Object Verb

# Get help and examples
Get-Help New-WinRarSFX -Full
Get-Help Install-Software -Examples
```

## 🤝 Contributing
Welcome contributions!
1. [Submit suggestions](https://github.com/AutomateSilent/QuickSoft/issues/new?template=suggestion.yml)
2. Submit a pull request

For detailed guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## 🐛 Issues and Support
- [Report a Bug](https://github.com/AutomateSilent/QuickSoft/issues/new?template=bug_report.yml)

## 📖 Documentation
- [Changelog](CHANGELOG.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Report a Bug](https://github.com/AutomateSilent/QuickSoft/issues/new?template=bug_report.yml)
- [LICENSE](LICENSE)
