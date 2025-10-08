# OMD Messenger Production Release Guide

This guide covers the complete process for creating a production release of OMD Messenger.

## TL;DR

Start the script `build-docker.sh` to produce a new docker image.

## Prerequisites

1. **Node.js Version**: Ensure you're using Node.js 20+
   ```bash
   nvm use 22  # or your preferred version >=20
   node --version  # Verify version
   ```

2. **Clean Environment**: Start with a clean build
   ```bash
   yarn clean
   ```

## Production Build Process

### Step 1: Configure for OMD Branding
```bash
# Build OMD-specific configuration
yarn config:omd

# Verify configuration was created
cat config.json | grep "OMD Messenger"
```

### Step 2: Production Build
```bash
# Full production build
yarn build

# This runs:
# - yarn clean (cleans previous builds)
# - yarn build:genfiles (copies resources and builds module system)
# - yarn build:bundle (webpack production build)
```

### Step 3: Verify Build Output
```bash
# Check webapp directory was created
ls -la webapp/

# Verify OMD assets are included
ls -la webapp/img/omd-dus.jpg
ls -la webapp/themes/omd/

# Check bundle files
ls -la webapp/bundles/
```

## Build Outputs

After a successful build, you'll have:

```
webapp/
├── index.html              # Main HTML file
├── config.json            # OMD configuration
├── bundles/               # JavaScript bundles
├── themes/omd/           # OMD theme assets
├── img/omd-dus.jpg       # OMD background image
├── vector-icons/         # App icons
└── ...                   # Other assets
```

## Deployment Options

### Option 1: Static Web Server
The `webapp/` directory contains all static files needed for deployment:

```bash
# Copy webapp contents to your web server
cp -r webapp/* /path/to/your/webserver/root/

# Or create a tarball for deployment
tar -czf omd-messenger-$(date +%Y%m%d).tar.gz -C webapp .
```

### Option 2: Docker Deployment
Create a Dockerfile for containerized deployment:

```dockerfile
FROM nginx:alpine
COPY webapp/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Option 3: CDN/Cloud Storage
Upload the webapp contents to:
- AWS S3 + CloudFront
- Netlify
- Vercel
- GitHub Pages

## Environment-Specific Builds

### OMD Production Build
```bash
yarn config:omd && yarn build
```

### Element Compatible Build (for testing)
```bash
yarn config:element && yarn build
```

## Release Versioning

### Update Version Number
```bash
# Update package.json version
npm version patch  # or minor, major
```

### Git Tagging
```bash
# Create git tag for release
git add .
git commit -m "Production build v$(node -p "require('./package.json').version")"
git tag -a "v$(node -p "require('./package.json').version")" -m "OMD Messenger v$(node -p "require('./package.json').version")"
git push origin develop --tags
```

## CI/CD Pipeline Example

Create `.github/workflows/build-and-deploy.yml`:

```yaml
name: Build and Deploy OMD Messenger

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '22'
          cache: 'yarn'
      
      - name: Install dependencies
        run: yarn install --frozen-lockfile
      
      - name: Build OMD configuration
        run: yarn config:omd
      
      - name: Build production
        run: yarn build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: omd-messenger-webapp
          path: webapp/
      
      # Add deployment steps here
```

## Quality Assurance

### Pre-Release Checklist
- [ ] OMD branding appears correctly
- [ ] Custom background image loads
- [ ] Login/registration flows work
- [ ] Matrix server connection works
- [ ] Desktop notifications function
- [ ] Mobile responsiveness verified
- [ ] All custom URLs point to OMD domains

### Testing Commands
```bash
# Build and serve locally for testing
yarn config:omd && yarn build
cd webapp && python3 -m http.server 8080
# Test at http://localhost:8080
```

## Rollback Procedure

If issues arise:

```bash
# Quick rollback to Element branding
yarn config:element && yarn build

# Or revert to previous git tag
git checkout v1.11.0  # previous version
yarn config:omd && yarn build
```

## Monitoring and Maintenance

### Log Monitoring
Monitor your deployed application for:
- Matrix server connection issues
- Asset loading failures
- JavaScript errors
- Performance metrics

### Update Strategy
- Regular upstream Element updates
- Security patches
- Configuration updates
- Asset refreshes

## Distribution

### Internal Distribution
```bash
# Create distributable package
yarn dist  # If available, or:
tar -czf omd-messenger-release.tar.gz webapp/
```

### External Hosting
Upload webapp contents to your hosting provider following their deployment process.

## Troubleshooting

### Common Issues

1. **Assets not loading**: Verify webpack.config.js includes img copy pattern
2. **Wrong branding**: Ensure `yarn config:omd` was run before build
3. **Build failures**: Check Node.js version compatibility
4. **Performance issues**: Review bundle size with `yarn build-stats`

### Debug Build
```bash
# Build with source maps for debugging
NODE_ENV=development yarn build:bundle
```

This creates a production-ready OMD Messenger with your custom branding and configuration!