# Trellis Tools

A collection of tools to enhance your [Roots Trellis](https://roots.io/trellis/) workflow and configuration.

## Table of Contents

- [Tools Overview](#tools-overview)
  - [1. Trellis Updater](#1-trellis-updater)
  - [2. Nginx Image Configuration](#2-nginx-image-configuration)
  - [3. Browser Caching Configuration](#3-browser-caching-configuration)
  - [4. WordPress Migration Tools](#4-wordpress-migration-tools)
  - [5. Backup Tools](#5-backup-tools)
  - [6. Content Creation Tools](#6-content-creation-tools)
  - [7. GitHub PR Creation Script](#7-github-pr-creation-script)
  - [8. Theme Sync Script](#8-theme-sync-script)
  - [9. Provisioning Documentation](#9-provisioning-documentation)
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

Comprehensive documentation and commands for managing WordPress migrations, especially when using Trellis and Bedrock.

#### Features

- **Complete Trellis/Bedrock Migration Guide** - Step-by-step instructions for migrating from traditional WordPress hosting
- **Multiple Migration Strategies** - Choose between full Bedrock adoption or compatibility mode
- **Pre-Migration Planning** - Detailed checklists and preparation steps
- **Database Migration** - Best practices for database transfer and path conversions
- **Domain Migration Commands** - For single-site and multisite installations
- **Path Conversion Tools** - Converting from standard WordPress to Bedrock structure
- **Modern Trellis CLI Workflow** - Using the latest Trellis CLI tools
- **Multi-Site Server Management** - Running multiple WordPress sites on one Trellis server
- **Comprehensive Troubleshooting** - Solutions for common migration issues
- **Post-Migration Optimization** - Performance tuning and security hardening

#### Migration Guides

- **[Single-Site Migration: Regular WordPress to Trellis/Bedrock](migration/REGULAR-TO-TRELLIS.md)** - Complete 10-step guide for migrating a single WordPress site from shared hosting, Plesk, or cPanel environments to a modern Trellis/Bedrock stack. Covers prerequisites, two migration approaches (full adoption vs. compatibility mode), server provisioning with Trellis CLI, file and database migration, and extensive troubleshooting guidance.
- **[Multi-Site Migration Guide](migration/MULTI-SITE-MIGRATION.md)** - Strategies and best practices for migrating **multiple WordPress sites to a single Trellis server**. Covers time-saving tips, batch operations, parallel processing, managing multiple Bedrock installations, and common pitfalls to avoid when consolidating sites.
- **[WordPress Migration Commands Reference](migration/README.md)** - Quick reference for WP-CLI commands including domain migrations, multisite handling, and Bedrock path conversions

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

### 6. Content Creation Tools

Comprehensive documentation and techniques for creating and managing WordPress content using WP-CLI, block patterns, and shell scripting.

#### Features

- **WP-CLI Content Management** - Create, update, and manage WordPress pages and posts from the command line
- **Block Pattern Integration** - Use WordPress block patterns in automated content creation
- **Remote Content Operations** - Update content on remote servers via Trellis
- **Batch Content Updates** - Scripts for updating multiple pages at once
- **Pattern Categories Reference** - Organized catalog of block pattern types and use cases
- **Complete Workflow Examples** - Real-world examples for common content operations

#### Usage

The content creation tools are particularly useful for:

- Automating page creation with pre-designed block patterns
- Bulk updating content across multiple pages
- Deploying standardized page layouts
- Managing content in Bedrock/Trellis environments

**Basic WP-CLI Operations:**
```bash
# Create a new page
wp post create --post_type=page --post_title="My Page" --post_status=publish --path=web/wp

# Update page content with block patterns
wp post update 100 --post_content="$(cat page-content.html)" --path=web/wp

# Remote operations via Trellis
trellis vm shell --workdir /srv/www/example.com/current -- wp post list --path=web/wp
```

For detailed instructions, block pattern examples, and automation workflows, please refer to the [Content Creation Guide](content-creation/README.md).

### 7. GitHub PR Creation Script

An intelligent script that creates GitHub pull requests with professional, AI-powered descriptions similar to GitHub Copilot.

#### Features

- **AI-Powered Descriptions** - Uses Claude CLI to analyze git diffs and generate intelligent PR summaries
- **Professional Formatting** - Creates descriptions with grouped sections, bold headings, and detailed bullet points
- **Clickable File Links** - Each changed file links directly to GitHub for quick review
- **Smart Categorization** - Automatically detects change types (dependencies, documentation, styling, etc.)
- **Token Efficient** - Uses 70-85% fewer tokens compared to manual PR creation with Claude
- **Fallback Mode** - Works without AI when using `--no-ai` flag (zero token usage)
- **Update Existing PRs** - Can regenerate descriptions for existing pull requests

#### Usage

The [create-pr.sh](create-pr.sh) script integrates with Claude CLI and GitHub CLI to automate PR creation:

**Interactive Mode:**
```bash
# Interactive prompts for base branch, title, and AI usage
./create-pr.sh
```

**Non-Interactive Mode:**
```bash
# Specify all parameters
./create-pr.sh main "Add new feature"

# Skip all prompts, use defaults
./create-pr.sh --no-interactive

# Skip AI generation (0 tokens, basic description)
./create-pr.sh --no-ai

# Update existing PR description
./create-pr.sh --update
```

**Prerequisites:**
- GitHub CLI (`gh`) - Required for PR creation
- Claude CLI - Optional, for AI-powered descriptions (automatically available if using Claude Code in VS Code)

For detailed usage, token comparison, and customization options, please refer to the [PR Creation Script Documentation](CREATE-PR.md).

### 8. Theme Sync Script

A simple rsync script to synchronize theme files from your Trellis project to a standalone theme repository, useful for theme development workflows.

#### Features

- One-way sync from Trellis to theme repository
- Automatically excludes dependencies and git files (node_modules, vendor, .git)
- Uses rsync for efficient file synchronization
- Preserves file permissions and timestamps

#### Usage

The [rsync-theme.sh](rsync-theme.sh) script needs to be customized with your specific paths:

1. Edit the script to set your source and destination paths:
   - Source: Your theme location within the Trellis project (e.g., `~/code/yoursite.com/site/web/app/themes/yourtheme/`)
   - Destination: Your standalone theme repository (e.g., `~/code/yourtheme/`)

2. Make the script executable:
   ```bash
   chmod +x rsync-theme.sh
   ```

3. Run the script whenever you want to sync changes:
   ```bash
   ./rsync-theme.sh
   ```

The script uses `rsync` with the `--delete` flag, which means files deleted from the source will also be deleted from the destination.

### 9. Provisioning Documentation

Quick reference guide for common Trellis provisioning commands and workflows.

#### Features

- Development environment provisioning commands
- Deployment commands for staging and production
- Server re-provisioning with specific tags
- PHP version upgrade process and best practices

For detailed provisioning commands and workflows, please refer to the [Provisioning Guide](provision/README.md).

## Requirements

### Core Requirements
- Git
- Bash
- rsync

### Tool-Specific Requirements
- **Backup Tools**: Ansible, WP-CLI, Trellis
- **Image Optimization**: ImageMagick, cwebp, cavif
- **Content Creation**: WP-CLI, Trellis (for remote operations)
- **PR Creation**: GitHub CLI (`gh`), Claude CLI (optional, for AI descriptions)

## License

MIT License. See [LICENSE.md](LICENSE.md) for details.

## Author

Copyright © Imagewize