# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in xBrew, please report it by emailing **security@xdev.asia**.

**Please do not report security vulnerabilities through public GitHub issues.**

### What to include in your report:

- Type of vulnerability
- Full paths of source file(s) related to the manifestation of the vulnerability
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to expect:

- We will acknowledge receipt of your vulnerability report within 48 hours
- We will send you regular updates about our progress
- We will notify you when the vulnerability is fixed
- We may ask for additional information or guidance

## Security Best Practices

When using xBrew:

1. **Keep the app updated** to the latest version
2. **Review permissions** granted to the app in System Settings
3. **Be cautious** when adding third-party taps
4. **Verify** package sources before installation
5. **Report** any suspicious behavior immediately

## Sandboxing

xBrew runs in a sandboxed environment with limited system access:

- Read/write access to `/opt/homebrew/` and `/usr/local/` (Homebrew directories only)
- Network access for downloading packages
- iCloud access for Brewfile sync (optional)

All permissions are declared in `xBrew.entitlements`.

## Code Scanning

This repository uses:

- **CodeQL** for automated vulnerability scanning
- **Dependabot** for dependency updates
- **GitHub Security Advisories** for coordinated disclosure

## Contact

For security concerns: **security@xdev.asia**  
For general issues: [GitHub Issues](https://github.com/your-username/xBrew/issues)
