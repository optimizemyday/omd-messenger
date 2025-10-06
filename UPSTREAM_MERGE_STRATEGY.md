# Upstream Merge Strategy for OMD Messenger

This document outlines the strategy for merging upstream Element Web changes while preserving OMD branding.

## High-Risk Conflict Files

These files contain OMD-specific changes and will likely conflict during upstream merges:

### Configuration Files
- `src/SdkConfig.ts` - Contains all default branding configurations
- `config.sample.json` - Sample configuration with OMD branding
- `package.json` - Package name and repository URLs
- `res/manifest.json` - Web app manifest with OMD branding

### HTML Templates
- `src/vector/index.html` - Page title and meta tags
- `src/vector/mobile_guide/index.html` - Mobile guide branding
- `src/vector/static/unable-to-load.html` - Error page links
- `res/welcome.html` - Welcome page branding

### React Components
- `src/components/views/auth/AuthHeaderLogo.tsx` - Logo paths
- `src/components/views/auth/Welcome.tsx` - Logo fallback paths
- `src/components/views/auth/AuthFooter.tsx` - Footer links
- `.storybook/ElementTheme.ts` - Storybook branding

### Documentation
- `README.md` - Project description and branding

## Merge Strategy

### 1. Preparation Before Merge
```bash
# Create a backup branch of current OMD customizations
git checkout -b omd-branding-backup

# Return to develop branch
git checkout develop

# Add upstream Element Web as remote (if not already added)
git remote add upstream https://github.com/element-hq/element-web.git
git fetch upstream
```

### 2. Merge Process
```bash
# Attempt merge with upstream
git merge upstream/develop

# Handle conflicts file by file
git status  # Shows conflicted files
```

### 3. Conflict Resolution Strategy

For each conflicted file:

#### A. Accept Upstream Changes First
```bash
git checkout --theirs <file>  # Accept upstream version
```

#### B. Re-apply OMD Branding
Use this document and `REBRANDING.md` to systematically re-apply OMD customizations.

#### C. Mark as Resolved
```bash
git add <file>
```

### 4. Automated Re-branding Script

Consider creating a script to automate common branding changes:

```bash
#!/bin/bash
# reapply-omd-branding.sh

# Update package.json
sed -i 's/"element-web"/"omd-messenger"/g' package.json
sed -i 's/Element: the future of secure communication/OMD Messenger: secure communication for OMD/g' package.json

# Update manifest.json
sed -i 's/"Element"/"OMD Messenger"/g' res/manifest.json

# Update index.html title
sed -i 's/<title>Element<\/title>/<title>OMD Messenger<\/title>/g' src/vector/index.html

# Add more automated replacements as needed...
```

## Low-Risk Files

These files are less likely to conflict:

### Custom OMD Files (Safe)
- `config.omd.json` - OMD-specific configuration
- `res/themes/omd/` - OMD theme directory
- `REBRANDING.md` - Documentation
- `UPSTREAM_MERGE_STRATEGY.md` - This file

### Asset Files (Rarely Change)
- `res/vector-icons/favicon.ico` - OMD favicon
- `src/vector/mobile_guide/assets/omd-messenger-logo.svg` - OMD mobile logo

## Best Practices

### 1. Regular Upstream Tracking
```bash
# Check for upstream changes regularly
git fetch upstream
git log --oneline develop..upstream/develop
```

### 2. Small, Frequent Merges
- Merge upstream changes frequently (monthly/quarterly)
- Smaller changes = easier conflict resolution

### 3. Maintain Clean Branding Patches
- Keep branding changes minimal and focused
- Document all customizations thoroughly
- Consider using git patches for repeatable branding application

### 4. Test After Each Merge
- Full functionality testing
- Verify all OMD branding is preserved
- Check configuration loading
- Test build process

## Emergency Recovery

If branding is accidentally lost:

```bash
# Restore from backup branch
git checkout omd-branding-backup -- src/SdkConfig.ts
git checkout omd-branding-backup -- config.omd.json
# ... restore other critical files

# Or use the rebranding script
./reapply-omd-branding.sh
```

## Alternative Approach: Rebase Strategy

Instead of merging, consider rebasing your OMD changes:

```bash
# Rebase OMD changes on top of latest upstream
git rebase upstream/develop

# Handle conflicts during rebase
# This keeps a cleaner history but requires more conflict resolution
```

## Configuration Management

### Environment-Based Configs ✅ IMPLEMENTED
OMD Messenger now uses environment-specific configuration system:

```
config/
├── base.json           # Common settings
├── element.json        # Original Element branding
└── omd.json           # OMD-specific overrides
```

**Usage:**
```bash
# Build OMD configuration
yarn config:omd

# Build Element configuration (for testing upstream compatibility)
yarn config:element

# Start development with OMD branding
yarn config:omd && yarn start
```

**Benefits:**
- Branding isolated from source code
- Minimal conflicts during upstream merges
- Easy to switch between Element and OMD branding
- Clean separation of concerns

See `CONFIG_SYSTEM.md` for detailed documentation.

### Improved Merge Process

With the configuration system, upstream merges become much simpler:

1. **Most source files**: No conflicts (branding removed from source)
2. **Configuration files**: Isolated conflicts, easy to resolve
3. **Asset files**: Usually no conflicts

**New Merge Workflow:**
```bash
# 1. Merge upstream with fewer conflicts
git merge upstream/develop

# 2. Resolve any config file conflicts
git add config/

# 3. Rebuild OMD configuration
yarn config:omd

# 4. Test and deploy
yarn start
```