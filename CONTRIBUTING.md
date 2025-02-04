# Contributing to QuickSoft

First off, thank you for considering contributing to QuickSoft! It's people like you that make QuickSoft such a great tool.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:
- Use welcoming and inclusive language
- Be respectful of different viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- Use a clear and descriptive title
- Describe the exact steps which reproduce the problem
- Provide specific examples to demonstrate the steps
- Describe the behavior you observed after following the steps
- Explain which behavior you expected to see instead and why
- Include PowerShell version (`$PSVersionTable`)
- Include QuickSoft version (`Get-Module QuickSoft`)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- A clear and descriptive title
- A step-by-step description of the suggested enhancement
- Any possible drawbacks
- Why this enhancement would be useful to most QuickSoft users

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing style
6. Write a convincing description of your PR and why we should land it

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

- Update README.md if needed
- Update comment-based help in functions
- Update CHANGELOG.md for notable changes
- Add examples for new features

## Questions?

Feel free to open an issue with the "question" tag.