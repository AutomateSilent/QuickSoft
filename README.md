# 🚀 QuickSoft PowerShell Module

![Test PowerShell Module](https://github.com/AutomateSilent/QuickSoft/workflows/Test%20PowerShell%20Module/badge.svg)

## 📖 Overview
QuickSoft is a robust PowerShell module designed for streamlined software management and system monitoring. Built with automation in mind, it simplifies software inventory, deployment detection, and system monitoring tasks.

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
1. Download and extract the module
2. Place in one of these locations:
   ```powershell
   # Current User (Recommended)
   $env:USERPROFILE\Documents\WindowsPowerShell\Modules\QuickSoft

   # All Users (Requires Admin)
   $env:ProgramFiles\WindowsPowerShell\Modules\QuickSoft
   ```
3. Import and verify:
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
Get-Help Get-Software -Full
Get-Help Get-Software -Examples
```
Quick Tip: Use tab completion to explore commands and parameters.

## 🤝 Contributing
We welcome contributions! Please follow these steps:
1. 🍴 Fork the repository
2. 🌿 Create a feature branch
3. ✍️ Make your changes
4. 📝 Update documentation
5. 🧪 Add/update tests
6. 📦 Submit a pull request

### Development Guidelines
- Use approved verbs (`Get-Verb` for list)
- Include comment-based help
- Maintain backward compatibility
- Add proper error handling

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues and Support
- Report bugs via GitHub Issues
- Check existing issues before reporting
- Include PowerShell and OS version details
- Provide minimal reproduction steps

## 🔄 Version History
See [CHANGELOG.md](CHANGELOG.md) for version history and updates.