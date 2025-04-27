# Trellis Tools

A collection of tools to enhance your [Roots Trellis](https://roots.io/trellis/) workflow and configuration.

## Tools Overview

### 1. Trellis Updater

A Bash script to safely update your Trellis installation while preserving your custom configurations.

#### Features

- Creates a backup of your current Trellis directory
- Downloads the latest version of Trellis
- Updates your Trellis files while preserving important configurations
- Commits changes to your Git repository

For detailed usage instructions and information, please refer to the [Trellis Updater documentation](updater/README.md).

> **Note:** If you prefer not to use the automated shell script, we also provide a [manual update guide](updater/manual-update.md) with step-by-step instructions.

### 2. Nginx Image Configuration

Tools to configure Nginx for optimized image serving, supporting WebP and AVIF formats.

#### Features

- Automatically serves WebP or AVIF images when browsers support them
- Falls back to traditional formats for older browsers
- Improves page load times and performance scores

#### Usage

The configuration is located in the `image-optimization/nginx-includes/webp-avf.conf.j2` file. 

For detailed instructions on implementing this in your Trellis project and converting your images to WebP/AVIF formats, please refer to our [Image Optimization Guide](image-optimization/README.md).

To implement this in your Trellis project:
1. Copy the `image-optimization/nginx-includes` directory to your Trellis project
2. Update your Trellis configuration to include this Nginx configuration
3. Run the appropriate provisioning command to apply the changes:
   ```bash
   # For production environment
   trellis provision production
   
   # For staging environment
   trellis provision staging
   
   # For development environment
   trellis provision development
   ```

### 3. WordPress Migration Tools

Documentation and commands for managing WordPress migrations, especially when using Trellis and Bedrock.

#### Features

- Domain migration guides for single-site and multisite installations
- Path conversion from standard WordPress to Bedrock structure
- Best practices for search-replace operations
- Troubleshooting common migration issues

For detailed usage instructions and examples, please refer to the [WordPress Migration Guide](migration/README.md).

## Requirements

- Git
- Bash
- rsync

## License

MIT License. See [LICENSE.md](LICENSE.md) for details.

## Author

Copyright © Imagewize