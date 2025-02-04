# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of QuickSoft seriously. If you believe you have found a security vulnerability, please follow these steps:

1. **DO NOT** open a public issue
2. Send a private report to [automate.silent@gmail.com]
3. Include as much information as possible:
   - A clear description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact of the vulnerability
   - Suggested fix if available

## What to Expect

- A response within 7 days with:
  - A determination of the reported vulnerability
  - A timeline for a fix if accepted
  - Potential mitigations
- Regular updates on the progress of accepted vulnerabilities
- Credit in the security advisory when the issue is resolved

## Security Best Practices for Users

1. Always use the latest version
2. Review the change log before updating
3. Run the module with least privilege necessary
4. Validate scripts downloaded from the internet
5. Keep PowerShell updated to the latest version
6. Enable PowerShell logging and auditing in production

## Code Security Practices

- All code is reviewed before merging
- Dependencies are regularly updated
- Automated security scanning is performed
- Code signing is used for releases
- Input validation is performed on all parameters
- Secure string is used for sensitive data
- Proper error handling to prevent information disclosure
