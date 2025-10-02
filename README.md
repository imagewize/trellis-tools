# Trellis Tools

A collection of tools to enhance your [Roots Trellis](https://roots.io/trellis/) workflow and configuration.

## Table of Contents

- [Tools Overview](#tools-overview)
  - [1. Trellis Updater](#1-trellis-updater)
  - [2. Nginx Image Configuration](#2-nginx-image-configuration)
  - [3. Browser Caching Configuration](#3-browser-caching-configuration)
  - [4. WordPress Migration Tools](#4-wordpress-migration-tools)
  - [5. Backup Tools](#5-backup-tools)
  - [6. Provisioning Documentation](#6-provisioning-documentation)
- [Requirements](#requirements)
- [License](#license)
- [Author](#author)

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

### 3. Browser Caching Configuration

Tools to configure Nginx for optimal browser caching of static assets to improve website performance.

#### Features

- Configures appropriate cache durations for different file types (images, CSS, JavaScript, fonts)
- Prevents caching of HTML and admin areas to ensure fresh content
- Adds proper cache headers for all static assets
- Improves load times and reduces bandwidth usage for returning visitors

#### Usage

The configuration is located in the `browser-caching/nginx-includes/assets-expiry.conf.j2` file.

For detailed instructions on implementing this in your Trellis project and understanding the cache duration settings, please refer to our [Browser Caching Guide](browser-caching/README.md).

To implement this in your Trellis project:
1. Copy the `browser-caching/nginx-includes` directory to your Trellis project
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

### 4. WordPress Migration Tools

Documentation and commands for managing WordPress migrations, especially when using Trellis and Bedrock.

#### Features

- Domain migration guides for single-site and multisite installations
- Path conversion from standard WordPress to Bedrock structure
- Best practices for search-replace operations
- Troubleshooting common migration issues

For detailed usage instructions and examples, please refer to the [WordPress Migration Guide](migration/README.md).

### 5. Backup Tools

Comprehensive backup solutions for WordPress sites running on Trellis servers.

#### Features

- **Ansible Playbooks**: Automated database and files (uploads) backup, push, and pull operations between environments
- **Shell Scripts**: Standalone backup scripts for database and file backups using WP-CLI
- **Complete Site Backups**: Database, uploads, themes, plugins, and configuration backups
- **Automated Retention**: Configurable backup retention policies
- **Environment Management**: Seamless backup operations between development, staging, and production
- **Smart Compression**: Uses `.sql.gz` for database (optimal single-file compression) and `.tar.gz` for directories (preserves structure)

#### Usage

The backup tools include both Ansible playbooks for Trellis integration and standalone shell scripts:

**Trellis Ansible Playbooks:**
```bash
# Database operations
ansible-playbook backup/trellis/database-backup.yml -e site=example.com -e env=production
ansible-playbook backup/trellis/database-pull.yml -e site=example.com -e env=production
ansible-playbook backup/trellis/database-push.yml -e site=example.com -e env=staging

# Files (uploads) operations
ansible-playbook backup/trellis/files-backup.yml -e site=example.com -e env=production
ansible-playbook backup/trellis/files-pull.yml -e site=example.com -e env=production
ansible-playbook backup/trellis/files-push.yml -e site=example.com -e env=staging
```

**Standalone Scripts:**
```bash
# Complete site backup
./backup/scripts/site-backup.sh example.com

# Database-only backup
./backup/scripts/db-backup.sh example.com production
```

For detailed instructions, configuration options, and best practices, please refer to the [Backup Documentation](backup/README.md).

### 6. Provisioning Documentation

Quick reference guide for common Trellis provisioning commands and workflows.

#### Features

- Development environment provisioning commands
- Deployment commands for staging and production
- Server re-provisioning with specific tags
- PHP version upgrade process and best practices

For detailed provisioning commands and workflows, please refer to the [Provisioning Guide](provision/README.md).

## Requirements

- Git
- Bash
- rsync

## License

MIT License. See [LICENSE.md](LICENSE.md) for details.

## Author

Copyright © Imagewize