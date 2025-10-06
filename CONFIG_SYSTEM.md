# Environment-Specific Configuration System

This document explains how to use the environment-specific configuration system for OMD Messenger.

## Overview

The configuration system separates branding-specific settings from core application logic, making upstream merges much easier and allowing you to maintain multiple branded versions.

## Directory Structure

```
config/
├── base.json           # Common settings shared by all environments
├── element.json        # Original Element branding
├── omd.json           # OMD Messenger branding
└── [custom].json      # Additional custom environments
```

## Configuration Files

### `base.json`
Contains all common settings that don't vary between environments:
- Feature flags
- Integration settings
- Default UI preferences
- General application behavior

### `element.json`
Contains Element-specific branding:
- Element logos and URLs
- element.io domains
- Original Element branding

### `omd.json`
Contains OMD-specific branding:
- OMD logos and URLs
- optimizemyday.com domains
- OMD-specific configuration

## Usage

### Build Configuration Scripts

Use yarn/npm scripts to build environment-specific configurations:

```bash
# Build OMD Messenger configuration (default)
yarn config:omd

# Build Element configuration
yarn config:element

# Build configuration (defaults to OMD)
yarn config:build
```

### Manual Configuration Building

You can also run the script directly:

```bash
# Build specific environment
node scripts/build-config.js omd
node scripts/build-config.js element

# List available environments
node scripts/build-config.js invalid-env
```

### Development Workflow

1. **Local Development**: Use OMD configuration
   ```bash
   yarn config:omd
   yarn start
   ```

2. **Testing Element Compatibility**: Switch to Element configuration
   ```bash
   yarn config:element
   yarn start
   ```

3. **Production Deployment**: Build appropriate configuration
   ```bash
   yarn config:omd
   yarn build
   ```

## Adding New Environments

To add a new branded environment:

1. **Create configuration file**: `config/[environment].json`
2. **Add environment-specific overrides**:
   ```json
   {
     "brand": "Your Brand",
     "branding": {
       "auth_header_logo_url": "themes/yourbrand/logo.svg"
     },
     "default_server_config": {
       "m.homeserver": {
         "base_url": "https://matrix.yourdomain.com",
         "server_name": "yourdomain.com"
       }
     }
   }
   ```
3. **Add yarn script** to package.json:
   ```json
   "config:yourbrand": "node scripts/build-config.js yourbrand"
   ```

## Configuration Merging

The build script uses deep merging:
1. Loads `base.json` as foundation
2. Merges environment-specific overrides
3. Environment settings override base settings
4. Objects are merged recursively
5. Arrays are replaced entirely

## Benefits for Upstream Merging

### Before (Problematic)
- Branding mixed with core code
- Conflicts in every branded file
- Manual conflict resolution needed
- Risk of losing customizations

### After (Clean)
- Branding isolated in config files
- Core code remains unchanged
- Minimal conflicts during merges
- Easy to restore branding

## Integration with Build Process

### Development
The webpack dev server automatically picks up `config.json` changes.

### Production
Build process uses the active `config.json`:
```bash
# Set environment and build
yarn config:omd
yarn build
```

### CI/CD Integration
```yaml
# Example GitHub Actions
- name: Configure for OMD
  run: yarn config:omd

- name: Build application
  run: yarn build
```

## Migration from Hardcoded Configuration

If you have hardcoded branding in source files, migrate it to this system:

1. **Identify branding elements** in source code
2. **Move to configuration** files
3. **Update source code** to read from SdkConfig
4. **Test with both** environments

## Best Practices

### 1. Keep Base Configuration Updated
- Regularly sync base.json with upstream defaults
- Only include non-branded settings in base.json

### 2. Minimal Environment Overrides
- Only override what's different from base
- Keep environment files focused on branding

### 3. Consistent Naming
- Use clear, descriptive environment names
- Match script names to environment files

### 4. Version Control
- Commit all configuration files
- Use separate branches for different environments if needed

### 5. Testing
- Test application with each environment
- Verify configuration merging works correctly

## Troubleshooting

### Configuration Not Loading
Check that `config.json` exists and is valid JSON:
```bash
yarn config:omd
cat config.json | jq .  # Validate JSON
```

### Missing Environment
List available environments:
```bash
ls config/*.json
```

### Merge Conflicts
The configuration files might conflict during upstream merges, but they're isolated and easier to resolve than scattered branding throughout the codebase.

## Example: Upstream Merge Workflow

```bash
# 1. Backup current branding
git checkout -b backup-omd-config

# 2. Merge upstream changes
git checkout develop
git merge upstream/develop

# 3. Resolve conflicts in config files only
# (Much easier than resolving conflicts in multiple source files)

# 4. Test both environments
yarn config:element && yarn build  # Test Element compatibility
yarn config:omd && yarn build      # Test OMD branding

# 5. Deploy
yarn config:omd
yarn build
```

This approach dramatically reduces the complexity of maintaining a branded fork while staying current with upstream changes.