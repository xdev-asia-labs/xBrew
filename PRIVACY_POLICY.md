# Privacy Policy for xBrew

**Last Updated**: January 22, 2026

## Overview

xBrew ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains how xBrew handles information when you use our macOS application.

## Data Collection

**xBrew does NOT collect, store, transmit, or share any personal data.**

### What We DON'T Collect

- ❌ No personal information
- ❌ No usage analytics
- ❌ No crash reports
- ❌ No tracking cookies
- ❌ No advertising identifiers
- ❌ No behavioral data
- ❌ No network monitoring

### How xBrew Works

xBrew is a local-only application that:

1. **Runs entirely on your Mac** - All operations are performed locally on your device
2. **Executes Homebrew commands** - Interacts with the Homebrew package manager installed on your system
3. **Reads/writes local files** - Only accesses Homebrew directories and configuration files on your Mac
4. **No remote servers** - We do not operate any servers or cloud services that collect your data

## Optional Features

### iCloud Sync (Optional)

xBrew offers an **optional** iCloud sync feature for Brewfile backups:

- **User Control**: This feature is OFF by default and requires explicit user activation
- **Your iCloud Account**: Uses your personal iCloud account (not our servers)
- **What's Synced**: Only Brewfile configuration files (list of installed packages)
- **Apple's Privacy**: Subject to Apple's iCloud terms and privacy policy
- **No Access**: We cannot access your iCloud data

### Homebrew Network Activity

xBrew uses Homebrew to download packages:

- **Homebrew's Network**: Package downloads are handled by Homebrew, not xBrew
- **Third-Party**: Packages are downloaded from Homebrew's repositories or tap sources
- **No Monitoring**: xBrew does not monitor, log, or transmit information about what you download

## Permissions

xBrew requests the following macOS permissions:

### File System Access
- **Purpose**: Read and write Homebrew directories (`/opt/homebrew` or `/usr/local`)
- **What We Access**: Only Homebrew-related files and configurations
- **No Scanning**: We do not scan or access your personal files

### AppleEvents / Shell Execution
- **Purpose**: Execute Homebrew commands via terminal
- **What We Execute**: Only Homebrew CLI commands (brew install, brew update, etc.)
- **Transparency**: All commands are shown in real-time in the app's terminal output view

### Network Access
- **Purpose**: Allow Homebrew to download packages
- **Direct Connection**: Homebrew connects directly to package repositories
- **No Intermediary**: xBrew does not intercept or monitor network traffic

### iCloud (Optional)
- **Purpose**: Sync Brewfile to your iCloud Drive
- **User Controlled**: Only if you enable this feature
- **Your Account**: Uses your personal iCloud account

## Third-Party Services

### Homebrew
- xBrew is a GUI frontend for Homebrew
- Homebrew has its own privacy policy and terms
- Visit https://brew.sh for more information

### Package Sources
- Packages are downloaded from official Homebrew repositories and third-party taps
- Each tap/repository may have its own privacy policies
- xBrew has no control over third-party package sources

## Data Storage

All data stored by xBrew is stored **locally on your Mac**:

- **Preferences**: macOS UserDefaults (local only)
- **Cache**: Temporary package lists and metadata (local only)
- **Logs**: Terminal output history (local only, cleared on app restart)
- **Configuration**: App settings (local only)

**Location**: `~/Library/Containers/asia.xdev.xBrew/`

## Data Sharing

xBrew does NOT share any data with:
- Third parties
- Advertisers
- Analytics services
- Other users
- Our servers (we have none)

## Children's Privacy

xBrew does not collect data from anyone, including children under 13. The app is rated 4+ and is safe for all ages.

## Your Rights

Since we don't collect any data, there is no data to:
- Request access to
- Request deletion of
- Request correction of
- Request portability of

## Security

xBrew uses macOS sandbox security:
- **Sandboxed Application**: Restricted file system access
- **No Root Access**: Does not require administrator privileges for most operations
- **Signed & Notarized**: App is signed with Apple Developer certificate
- **Hardened Runtime**: Enhanced security protections enabled

## Changes to Privacy Policy

We may update this Privacy Policy from time to time. Changes will be posted:
- In the app's About section
- On our GitHub repository
- On the Mac App Store listing

## Contact Us

If you have questions about this Privacy Policy:

- **Email**: support@xdev.asia
- **GitHub Issues**: https://github.com/xdev-asia-labs/xBrew/issues
- **Website**: https://github.com/xdev-asia-labs/xBrew

## Compliance

This Privacy Policy complies with:
- Apple's App Store Review Guidelines
- macOS App Sandbox requirements
- General Data Protection Regulation (GDPR) principles
- California Consumer Privacy Act (CCPA) principles

## Summary

**In simple terms**: xBrew is a privacy-first application that works entirely on your Mac. We don't collect, store, or share any of your personal information. Everything stays on your device.

---

**Company Information**

xDev Asia Labs  
Contact: support@xdev.asia  
Location: Vietnam

© 2026 xDev Asia Labs. All rights reserved.
