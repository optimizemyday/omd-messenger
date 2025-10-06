# OMD Messenger Rebranding Summary

This document summarizes the changes made to rebrand Element Web to OMD Messenger.

## Changes Made

### 1. Configuration Files
- **config.sample.json**: Updated brand name from "Element" to "OMD Messenger"
- **config.omd.json**: Created new OMD-specific configuration file with:
  - OMD branding settings
  - Custom logo paths
  - OMD-specific URLs and domains
  - Custom footer links

### 2. Source Code Configuration
- **src/SdkConfig.ts**: Updated default configurations:
  - Brand name: "Element" → "OMD Messenger"
  - Element Call brand: "Element Call" → "OMD Call"
  - Help URLs: element.io → docs.omd.com
  - Jitsi domain: meet.element.io → meet.omd.com
  - Desktop/mobile download URLs updated to OMD domains

### 3. HTML Templates and Static Files
- **src/vector/index.html**:
  - Page title: "Element" → "OMD Messenger"
  - App metadata updated
- **src/vector/mobile_guide/index.html**:
  - Title and logo references updated
  - "Join Element" → "Join OMD Messenger"
- **src/vector/static/unable-to-load.html**:
  - Error messages updated
  - Links updated to omd.com
- **res/welcome.html**:
  - Welcome message updated
  - Logo link updated to omd.com

### 4. React Components
- **src/components/views/auth/AuthHeaderLogo.tsx**:
  - Default logo path: themes/element/... → themes/omd/...
  - Alt text: "Element" → "OMD Messenger"
- **src/components/views/auth/Welcome.tsx**:
  - Default logo path updated
- **src/components/views/auth/AuthFooter.tsx**:
  - Footer links updated to OMD-specific URLs

### 5. Project Metadata
- **package.json**:
  - Package name: "element-web" → "omd-messenger"
  - Description updated
  - Repository URL updated
- **res/manifest.json**:
  - App name: "Element" → "OMD Messenger"
  - Mobile app store URLs updated
- **README.md**:
  - Title and description updated
  - Environment support references updated

### 6. Logo and Asset Files
- **Created new theme directory**: `res/themes/omd/img/logos/`
- **Copied OMD logos**:
  - `omd-messenger-logo.svg` (main logo)
  - `omd-app-logo.svg` (application logo)
- **Updated favicon**: Replaced Element favicon with OMD favicon
- **Mobile guide logo**: Updated to OMD blue logo

### 7. Storybook Configuration
- **.storybook/ElementTheme.ts**:
  - Brand title: "Element Web" → "OMD Messenger Web"
  - Brand URLs updated to OMD domains

## Logo Files Added
- `res/themes/omd/img/logos/omd-messenger-logo.svg` - Main OMD logo
- `res/themes/omd/img/logos/omd-app-logo.svg` - Full OMD application logo
- `src/vector/mobile_guide/assets/omd-messenger-logo.svg` - Mobile guide logo
- `res/vector-icons/favicon.ico` - OMD favicon (replaced)

## Configuration Usage
To use the OMD-specific configuration, copy `config.omd.json` to `config.json` in your deployment.

## Domain Changes
- element.io → optimizemyday.com
- packages.element.io → packages.optimizemyday.com
- meet.element.io → meet.optimizemyday.com
- call.element.io → call.optimizemyday.com
- docs URLs → docs.optimizemyday.com

## Mobile App Identifiers
- iOS: Still uses placeholder ID (update when OMD app is published)
- Android: im.vector.app → com.optimizemyday.messenger
- F-Droid: im.vector.app → com.optimizemyday.messenger

## Next Steps
1. Review and test the application with the new branding
2. Update any remaining Element references as needed
3. Configure proper OMD Matrix homeserver
4. Deploy with OMD-specific configuration
5. Update mobile app store references when OMD apps are published