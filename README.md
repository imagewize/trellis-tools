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

A Bash script to safely update your Trellis installation while preserving your custom configurations. Creates backups, downloads the latest version, and commits changes to Git.

For detailed usage instructions, see the [Trellis Updater documentation](updater/README.md) or the [manual update guide](updater/manual-update.md).

### 2. Nginx Image Configuration

Configure Nginx to automatically serve WebP and AVIF images when browsers support them, falling back to traditional formats for older browsers. Improves page load times and performance scores.

See the [Image Optimization Guide](image-optimization/README.md) for setup instructions and image conversion workflows.

### 3. Browser Caching Configuration

Nginx configuration for optimal browser caching of static assets. Configures appropriate cache durations for different file types while preventing caching of HTML and admin areas.

See the [Browser Caching Guide](browser-caching/README.md) for implementation instructions and cache duration settings.

### 4. WordPress Migration Tools

Comprehensive guides and commands for migrating WordPress sites to Trellis/Bedrock. Includes step-by-step instructions, migration strategies, database transfer, path conversions, and troubleshooting.

**Migration Guides:**
- [Single-Site Migration: Regular WordPress to Trellis/Bedrock](migration/REGULAR-TO-TRELLIS.md) - Complete 10-step guide
- [Multi-Site Migration Guide](migration/MULTI-SITE-MIGRATION.md) - Migrating multiple sites to one Trellis server
- [WordPress Migration Commands Reference](migration/README.md) - WP-CLI commands for migrations

### 5. Backup Tools

Automated backup solutions for WordPress sites on Trellis servers. Includes Ansible playbooks for database and files (uploads) backup, push, and pull operations between environments, plus standalone shell scripts.

See the [Backup Documentation](backup/README.md) for commands, configuration, and best practices.

### 6. Content Creation Tools

Documentation and techniques for creating and managing WordPress content using WP-CLI and block patterns. Includes workflows for automated page creation, batch updates, and remote content operations.

See the [Content Creation Guide](content-creation/README.md) for WP-CLI commands, block pattern examples, and automation workflows.

### 7. GitHub PR Creation Script

Intelligent script that creates GitHub pull requests with AI-powered descriptions. Uses Claude CLI to analyze git diffs and generate professional summaries with grouped sections, clickable file links, and smart categorization. Uses 70-85% fewer tokens than manual creation, or run with `--no-ai` for zero token usage.

See the [PR Creation Script Documentation](CREATE-PR.md) for usage, token comparison, and customization options.

### 8. Theme Sync Script

Simple rsync script ([rsync-theme.sh](rsync-theme.sh)) to synchronize theme files from your Trellis project to a standalone theme repository. One-way sync with automatic exclusion of dependencies and git files.

### 9. Provisioning Documentation

Quick reference guide for common Trellis provisioning commands, deployment workflows, server re-provisioning with tags, and PHP version upgrades.

See the [Provisioning Guide](provision/README.md) for detailed commands and workflows.

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