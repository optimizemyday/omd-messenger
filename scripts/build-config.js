#!/usr/bin/env node

/**
 * Configuration Builder for OMD Messenger
 * 
 * Merges base configuration with environment-specific overrides
 * Usage: node scripts/build-config.js [environment]
 * 
 * Environments:
 * - element: Original Element branding
 * - omd: OMD Messenger branding (default)
 */

const fs = require('fs');
const path = require('path');

function loadJsonFile(filePath) {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        return JSON.parse(content);
    } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
        process.exit(1);
    }
}

function deepMerge(target, source) {
    const result = { ...target };
    
    for (const key in source) {
        if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
            result[key] = deepMerge(result[key] || {}, source[key]);
        } else {
            result[key] = source[key];
        }
    }
    
    return result;
}

function buildConfig(environment = 'omd') {
    const configDir = path.join(__dirname, '..', 'config');
    const outputPath = path.join(__dirname, '..', 'config.json');
    
    // Load base configuration
    const baseConfig = loadJsonFile(path.join(configDir, 'base.json'));
    
    // Load environment-specific configuration
    const envConfigPath = path.join(configDir, `${environment}.json`);
    if (!fs.existsSync(envConfigPath)) {
        console.error(`Environment configuration not found: ${environment}.json`);
        console.log('Available environments:');
        const configs = fs.readdirSync(configDir)
            .filter(f => f.endsWith('.json') && f !== 'base.json')
            .map(f => f.replace('.json', ''));
        configs.forEach(env => console.log(`  - ${env}`));
        process.exit(1);
    }
    
    const envConfig = loadJsonFile(envConfigPath);
    
    // Merge configurations
    const finalConfig = deepMerge(baseConfig, envConfig);
    
    // Write output
    fs.writeFileSync(outputPath, JSON.stringify(finalConfig, null, 2) + '\n');
    
    console.log(`✅ Configuration built for environment: ${environment}`);
    console.log(`📁 Output: ${outputPath}`);
    
    // Log key branding information
    console.log(`🏷️  Brand: ${finalConfig.brand}`);
    console.log(`🏠 Homeserver: ${finalConfig.default_server_config?.['m.homeserver']?.base_url || 'Not configured'}`);
    console.log(`🎨 Logo: ${finalConfig.branding?.auth_header_logo_url || 'Default'}`);
}

// Parse command line arguments
const environment = process.argv[2];
buildConfig(environment);