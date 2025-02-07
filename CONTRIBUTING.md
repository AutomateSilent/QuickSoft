#  🎊 Contributing to QuickSoft

First off, thank you for considering contributing to QuickSoft! It's people like you that make QuickSoft such a great tool.

## 📖 Code of Conduct

By participating in this project, you are expected to:
- Use welcoming and inclusive language

##  How Can I Contribute?

* [Report a Bug](https://github.com/AutomateSilent/QuickSoft/issues/new?template=bug_report.yml)
* [Submit Suggestions or Enhancements](https://github.com/AutomateSilent/QuickSoft/issues/new?template=suggestion.yml)
  
  > Suggestions are tracked as GitHub issues.

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Make sure your code follows the existing style
4. Create [suggestion](https://github.com/AutomateSilent/QuickSoft/issues/new?template=suggestion.yml) if any question

## PowerShell Style Guide

- Use approved PowerShell verbs (`Get-Verb` to list them)
- Follow the naming conventions:
  - Functions: `Verb-Noun`
  - Parameters: PascalCase
  - Variables: PascalCase
- Include comment-based help for all functions
- Use proper error handling with try/catch blocks
- Write clear, descriptive comments
- Keep functions focused and modular

## Development Process

1. Clone the repository
2. Install development dependencies:
   ```powershell
   Install-Module Pester -Force
   Install-Module PSScriptAnalyzer -Force
   ```
3. Make your changes
4. Run tests:
   ```powershell
   Invoke-Pester ./Tests
   ```
5. Run script analysis:
   ```powershell
   Invoke-ScriptAnalyzer -Path .
   ```

## Documentation

- Update comment-based help in functions
- Update CHANGELOG.md for notable changes

## Questions?

Feel free to open an issue with the "question" or "suggestion" tag.
