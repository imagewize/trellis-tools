# Migrating from Regular WordPress to Trellis with Bedrock

This guide covers the complete process of migrating a standard WordPress installation (from shared hosting, Plesk, cPanel, etc.) to a [Roots Trellis](https://roots.io/trellis/) server running [Bedrock](https://roots.io/bedrock/). This is particularly useful when you need to modernize your WordPress infrastructure while maintaining a non-Sage theme.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Migration Approaches](#migration-approaches)
- [Choosing Your Migration Workflow](#choosing-your-migration-workflow)
- [Pre-Migration Checklist](#pre-migration-checklist)
- [Quick Migration Checklist (Per Site)](#quick-migration-checklist-per-site)
- [Step-by-Step Migration Process](#step-by-step-migration-process)
  - [Migration Workflow Overview](#migration-workflow-overview)
  - [1. Set Up Trellis and Bedrock Locally](#1-set-up-trellis-and-bedrock-locally)
  - [2. Provision Your Server](#2-provision-your-server)
  - [3. Prepare Your Existing WordPress Site](#3-prepare-your-existing-wordpress-site)
  - [4. Transfer Theme and Plugins to Local Bedrock](#4-transfer-theme-and-plugins-to-local-bedrock)
  - [5. Deploy Bedrock to Server](#5-deploy-bedrock-to-server)
  - [6. Migrate the Database](#6-migrate-the-database)
  - [7. Migrate Uploads](#7-migrate-uploads)
  - [Alternative: Using Automated Backup Playbooks](#alternative-using-automated-backup-playbooks-workflow-b)
  - [8. Choose Your Path Migration Strategy](#8-choose-your-path-migration-strategy)
  - [9. Test and Verify](#9-test-and-verify)
  - [10. DNS and Go-Live](#10-dns-and-go-live)
- [Time-Saving Tips for Multiple Sites](#time-saving-tips-for-multiple-sites)
- [Managing Multiple Sites on One Server](#managing-multiple-sites-on-one-server)
- [Common Pitfalls When Migrating Multiple Sites](#common-pitfalls-when-migrating-multiple-sites)
- [Troubleshooting](#troubleshooting)
- [Post-Migration Optimization](#post-migration-optimization)

## Overview

Bedrock restructures WordPress directories from the traditional layout to a more modern, secure structure:

**Traditional WordPress:**
```
/
├── wp-admin/
├── wp-content/
│   ├── themes/
│   ├── plugins/
│   └── uploads/
├── wp-includes/
└── wp-config.php
```

**Bedrock Structure:**
```
/
├── web/
│   ├── app/
│   │   ├── themes/
│   │   ├── plugins/
│   │   ├── uploads/
│   │   └── mu-plugins/
│   ├── wp/              # WordPress core (subdirectory)
│   └── wp-config.php
├── config/
│   └── application.php
└── composer.json
```

## Prerequisites

- SSH access to your destination server (or a fresh server to provision)
- Root or sudo access for Trellis provisioning
- **Trellis CLI** installed (see installation below)
- Ansible installed locally (Trellis CLI will prompt if needed)
- WP-CLI installed on destination server (Trellis installs this automatically)
- Database backup of your existing site
- Download of your existing site's files (themes, plugins, uploads)
- Git repository for your project (GitHub, GitLab, Bitbucket, etc.)

## Migration Approaches

You have two main approaches for handling file paths:

### Approach A: Full Bedrock Adoption (Recommended)
Convert all database paths to Bedrock structure (`/app/uploads/`, `/app/themes/`). This is the cleanest approach and fully embraces Bedrock conventions.

**Pros:**
- Full compatibility with Bedrock ecosystem
- Cleaner, more maintainable structure
- Better for long-term maintenance

**Cons:**
- Requires database search-replace operations
- More steps in initial migration

### Approach B: Path Compatibility Mode
Keep using `/wp-content/uploads/` paths in the database by modifying Bedrock's configuration.

**Pros:**
- Minimal database changes
- Faster initial migration
- Useful if you need to maintain compatibility with legacy systems

**Cons:**
- Goes against Bedrock conventions
- May cause confusion for other developers
- Could complicate future updates

## Choosing Your Migration Workflow

You have two primary workflows for migrating your site(s), depending on whether you want to test locally first or migrate directly to production.

### Workflow A: Direct Server-to-Server Migration
**Best for:** Sites currently on shared hosting without local dev environment, or when you need to go live quickly.

**Process:**
1. Set up Trellis and Bedrock locally (Steps 1-2)
2. Deploy empty Bedrock to server (Step 5)
3. **Manually** transfer database and files from old hosting to new server (Steps 6-7)
4. Apply path conversions (Step 8)
5. Test and go live (Steps 9-10)

**Time per site:** 3-4 hours (first site), 2-3 hours (additional sites)

**Pros:**
- Fewer steps overall
- No need to set up local development environment
- Direct migration from old to new hosting

**Cons:**
- Less opportunity to test before going live
- Manual file transfers can be error-prone
- Harder to repeat if something goes wrong

### Workflow B: Local-First Migration (Recommended)
**Best for:** When you want to test locally before going live, or when managing multiple sites.

**Process:**
1. Set up Trellis and Bedrock locally (Steps 1-2)
2. Start local development environment (`trellis vm start`)
3. Import database and files to local environment
4. Test everything locally at `https://example.test`
5. Provision production server (Step 2)
6. **Use automated backup playbooks** to push from local to production
7. Test production and go live

**Time per site:** 4-5 hours (first site), 2.5-3.5 hours (additional sites)

**Pros:**
- Test thoroughly before going live
- Repeatable, automated process using playbooks
- Safer - production remains untouched until ready
- Easy to iterate if issues are found

**Cons:**
- Requires local development setup
- Additional step to transfer data twice (old → local → production)
- Requires Vagrant/VirtualBox for local VM

**Recommended for:** Three-site migration projects where consistency and testing are important.

## Pre-Migration Checklist

Before starting the migration:

- [ ] **Backup everything** from your current site
  - Database export (`.sql` or `.sql.gz`)
  - Complete file backup (themes, plugins, uploads)
  - Copy of `wp-config.php` for reference
- [ ] Document all active plugins and their versions
- [ ] Note any custom configurations or constants in `wp-config.php`
- [ ] Identify any hardcoded URLs in theme files
- [ ] Check for any symlinks or special file permissions
- [ ] Verify PHP version compatibility (source vs. destination)
- [ ] Test your site backup locally if possible

## Quick Migration Checklist (Per Site)

Use this condensed checklist to track progress for each site during migration.

### Pre-Migration (15-30 mins)
- [ ] Download database backup (`.sql` or `.sql.gz`)
- [ ] Download files (themes, plugins, uploads)
- [ ] Document active plugins and versions
- [ ] Generate WordPress salts (https://roots.io/salts.html)
- [ ] Create Git repository on GitHub/GitLab
- [ ] Note any custom `wp-config.php` settings

### Trellis Setup (First Site: 60 mins, Additional: 15 mins)
- [ ] Create Bedrock installation with descriptive name (`site-example`)
- [ ] Configure `wordpress_sites.yml` for development and production
- [ ] Edit vault files with database credentials and salts
- [ ] Update `hosts/production` with server IP
- [ ] Provision server (first site only - run once for all sites)
- [ ] Commit Trellis configuration to Git

### Site Preparation (30 mins)
- [ ] Copy theme to `site/web/app/themes/`
- [ ] Copy plugins to `site/web/app/plugins/`
- [ ] Add plugins to `composer.json` where possible
- [ ] Run `composer install`
- [ ] Commit and push to Git repository

### Deployment (15 mins)
- [ ] Deploy to production: `trellis deploy production`
- [ ] Verify deployment created correct directory structure
- [ ] Check symlinks are correct

### Data Migration (45-60 mins)

**Option A: Manual Migration (Workflow A)**
- [ ] Import database via WP-CLI or MySQL
- [ ] Update domain URLs with search-replace
- [ ] rsync/scp uploads directory
- [ ] Set correct permissions on uploads
- [ ] Run path conversion search-replace commands

**Option B: Automated with Playbooks (Workflow B - Recommended)**
- [ ] Import database and uploads to local development
- [ ] Test locally at `https://example.test`
- [ ] Run `ansible-playbook database-push.yml`
- [ ] Run `ansible-playbook files-push.yml`
- [ ] Verify on production

### Path Conversion (15 mins)
- [ ] Run search-replace for `/wp-content/themes/` → `/app/themes/`
- [ ] Run search-replace for `/wp-content/uploads/` → `/app/uploads/`
- [ ] Run search-replace for `/wp-content/plugins/` → `/app/plugins/`
- [ ] Verify no remaining `wp-content` references
- [ ] Flush cache and permalinks

### Testing (30 mins)
- [ ] Verify homepage loads correctly
- [ ] Check all images display properly
- [ ] Test navigation menus
- [ ] Verify forms work
- [ ] Test admin panel access
- [ ] Check plugin functionality
- [ ] Test media upload
- [ ] Verify SSL certificate
- [ ] Check browser console for errors

### Go-Live (15 mins)
- [ ] Lower DNS TTL 24 hours before
- [ ] Update DNS A record to new server IP
- [ ] Monitor DNS propagation
- [ ] Test site from multiple locations
- [ ] Keep old server running 24-48 hours

### Post-Migration (15 mins)
- [ ] Set up automated backups
- [ ] Enable Redis caching
- [ ] Configure monitoring
- [ ] Document any issues encountered
- [ ] Update team documentation

**Total Time Estimates:**
- **First site:** 4-6 hours (includes learning curve and server setup)
- **Second site:** 2.5-3.5 hours (server already provisioned)
- **Third site:** 2-3 hours (process is familiar)

**For three sites: 8-12 hours total**

## Step-by-Step Migration Process

### Migration Workflow Overview

The migration process follows this sequence:

1. **Local Setup**: Set up Trellis and Bedrock locally
2. **Configure Environments**: Configure your server settings and site configuration
3. **Provision Server**: Provision your production/staging server (creates directory structure, installs software)
4. **Prepare Bedrock Site**: Add your theme and plugins to local Bedrock site
5. **Initial Deployment**: Deploy Bedrock to server (creates `/srv/www/example.com/` structure)
6. **Migrate Database**: Import and transform database on server
7. **Migrate Uploads**: Transfer uploads directory to server
8. **Path Migration**: Choose and implement path migration strategy
9. **Test & Verify**: Comprehensive testing
10. **DNS & Go-Live**: Update DNS and go live

### 1. Set Up Trellis and Bedrock Locally

#### Install Trellis CLI

First, install the Trellis CLI if you haven't already:

```bash
# macOS (using Homebrew)
brew install roots/tap/trellis-cli

# Linux (using installation script)
curl -sL https://roots.io/trellis/cli/get | bash

# Verify installation
trellis --version
```

For other installation methods, see [Trellis CLI Installation](https://roots.io/trellis/docs/installation/).

#### Create New Trellis Project

The modern way to set up Trellis and Bedrock is using the Trellis CLI:

```bash
# Navigate to your projects directory
cd ~/code

# Create new project (this creates both Trellis and Bedrock)
trellis new example.com

# Navigate into the project
cd example.com
```

This command automatically:
- Creates the project directory
- Clones Trellis
- Clones Bedrock (in the `site/` directory)
- Installs Ansible Galaxy dependencies
- Initializes a Git repository
- Sets up basic configuration

#### Review and Configure Your Site

Now review and configure your site settings:

**1. Review development configuration:**

Edit `trellis/group_vars/development/wordpress_sites.yml` - this is already pre-configured for local development with `trellis vm`.

**2. Configure production environment:**

**Edit `trellis/group_vars/production/wordpress_sites.yml`:**

```yaml
wordpress_sites:
  example.com:
    site_hosts:
      - canonical: example.com
        redirects:
          - www.example.com
    local_path: ../site
    repo: git@github.com:yourusername/example.com.git  # Your Git repo URL
    repo_subtree_path: site
    branch: main  # Or master, depending on your Git setup
    multisite:
      enabled: false
    ssl:
      enabled: true
      provider: letsencrypt
    cache:
      enabled: true  # Enable FastCGI cache and Redis
```

**3. Configure production vault (encrypted secrets):**

Use Trellis CLI to edit the encrypted vault file:

```bash
# Edit production vault file
cd trellis
trellis vault edit production

# This opens the vault file in your default editor
# Update the WordPress salts and database password:
```

```yaml
vault_wordpress_sites:
  example.com:
    env:
      db_password: "generate_secure_password_here"
      # Generate salts at: https://roots.io/salts.html
      auth_key: "generateme"
      secure_auth_key: "generateme"
      logged_in_key: "generateme"
      nonce_key: "generateme"
      auth_salt: "generateme"
      secure_auth_salt: "generateme"
      logged_in_salt: "generateme"
      nonce_salt: "generateme"
```

**Important:** Generate WordPress salts at [https://roots.io/salts.html](https://roots.io/salts.html)

**4. Add your production server IP:**

Edit `trellis/hosts/production`:
```ini
[production]
your.server.ip.address

[web]
your.server.ip.address
```

**5. (Optional) Test locally first:**

Before provisioning production, you can test locally using Vagrant:

```bash
# Start local development VM
trellis vm start

# This provisions a local VM and deploys your site
# Access at: https://example.test
```

**6. Create Git repository and push:**

```bash
# From project root (example.com/)
cd ~/code/example.com

# Add all files (Git repo already initialized by trellis new)
git add .

# Initial commit
git commit -m "Initial Trellis and Bedrock setup"

# Create repository on GitHub/GitLab, then add remote
git remote add origin git@github.com:yourusername/example.com.git

# Push to remote
git push -u origin main
```

### 2. Provision Your Server

**IMPORTANT**: You must provision your server before deploying. This step installs all necessary software (Nginx, PHP, MariaDB, etc.) and creates the directory structure.

**Prerequisites for provisioning:**
- Fresh Ubuntu 22.04 or 24.04 server
- Root or sudo user access
- SSH key-based authentication set up

```bash
# From the trellis directory
cd ~/code/example.com/trellis

# Provision production server (this will take 10-15 minutes)
trellis provision production

# Alternative: Use ansible-playbook directly
# ansible-playbook server.yml -e env=production
```

This command will:
- Install and configure Nginx
- Install PHP and required extensions
- Install and configure MariaDB (MySQL)
- Create the directory structure at `/srv/www/example.com/`
- Set up SSL certificates with Let's Encrypt
- Configure Redis (if enabled)
- Set up proper user permissions

**Troubleshooting Provisioning:**

If provisioning fails, check:
```bash
# Verify SSH access to server (default user is usually 'root' or 'admin')
ssh root@your.server.ip.address

# Or if using a different user
ssh admin_user@your.server.ip.address

# Check Ansible can connect (from trellis directory)
cd ~/code/example.com/trellis
ansible production -m ping

# Verify server meets requirements (Ubuntu 22.04 or 24.04)
ssh root@your.server.ip.address "lsb_release -a"

# Check Ansible version (should be 2.10+)
ansible --version
```

For detailed provisioning commands and troubleshooting, see the [Provisioning Guide](../provision/README.md).

### 3. Prepare Your Existing WordPress Site

On your current hosting:

```bash
# Export the database
wp db export backup.sql --add-drop-table

# Or if WP-CLI is not available, use phpMyAdmin or command line:
mysqldump -u username -p database_name > backup.sql

# Create a compressed archive of your files
tar -czf site-backup.tar.gz wp-content/

# Or download specific directories:
# themes, plugins, and uploads
```

### 4. Transfer Theme and Plugins to Local Bedrock

Copy your theme(s) and plugins to your **local** Bedrock directory structure:

```bash
# In your local Bedrock directory (site/)

# Copy theme (from your backup)
cp -r /path/to/backup/wp-content/themes/your-theme web/app/themes/

# Copy plugins (from your backup)
cp -r /path/to/backup/wp-content/plugins/* web/app/plugins/

# Note: Try to install plugins via Composer when possible
# Example: composer require wpackagist-plugin/plugin-name
```

**Update `site/composer.json`** to include plugins available via Composer:

```json
{
  "require": {
    "php": ">=8.0",
    "roots/bedrock": "^1.21",
    "wpackagist-plugin/wordpress-seo": "^22.0",
    "wpackagist-plugin/wordfence": "^7.11"
  }
}
```

Run `composer install` to install plugins via Composer.

**Commit your changes to Git:**

```bash
# In your project root (not trellis directory)
cd /path/to/example.com

# Initialize git if not already done
git init

# Add site directory
git add site/

# Commit
git commit -m "Initial Bedrock setup with theme and plugins"

# Add remote (create repo on GitHub/GitLab first)
git remote add origin git@github.com:yourusername/example.com.git

# Push to remote
git push -u origin main
```

### 5. Deploy Bedrock to Server

Now deploy your Bedrock site to the provisioned server. This creates the directory structure and symlinks.

**Important for Multiple Sites:** If you're adding a second or third site to an already-provisioned server, you must **re-provision first** to create the new site's infrastructure (database, Nginx configuration, SSL certificate, and directory structure):

```bash
# From trellis directory
cd trellis

# FIRST: Re-provision if adding a new site to existing server
# This creates database, Nginx config, SSL cert for the new site
trellis provision production

# THEN: Deploy the site
trellis deploy production
```

**For the first site only** (server not yet provisioned), you can skip directly to deploy since you already provisioned in Step 2.

**What deployment does:**

This will:
- Clone your Git repository to `/srv/www/example.com/releases/TIMESTAMP/`
- Run `composer install` to install WordPress core and plugins
- Create symlinks:
  - `/srv/www/example.com/current` → latest release
  - `/srv/www/example.com/current/web/app/uploads` → `/srv/www/example.com/shared/uploads`
- Create `.env` file with database credentials
- Set proper permissions

**Verify deployment:**

```bash
# SSH into server
ssh admin_user@your.server.ip.address

# Check directory structure was created
ls -la /srv/www/example.com/
# Should show: current, releases, shared

# Check current symlink
ls -la /srv/www/example.com/current
# Should point to latest release

# Check uploads symlink
ls -la /srv/www/example.com/current/web/app/
# Should show: uploads -> ../../../shared/uploads
```

At this point, if you visit your domain (assuming DNS is pointed), you'll see the WordPress installation screen. **Don't run it yet** - we need to import your database first.

### 6. Migrate the Database

#### Option A: Using WP-CLI (Recommended)

On your source site, export the database:

```bash
# On source server or via SSH
wp db export source-backup.sql --add-drop-table
```

Import to your Trellis/Bedrock environment:

```bash
# SSH into your Trellis server
cd /srv/www/example.com/current

# Import the database
wp db import /path/to/source-backup.sql

# Update the site URL if domain is changing
wp search-replace 'http://old-domain.com' 'https://example.com' --dry-run
wp search-replace 'http://old-domain.com' 'https://example.com'

# Also replace without protocol
wp search-replace 'old-domain.com' 'example.com'
```

#### Option B: Manual Import

```bash
# Copy database dump to server
scp backup.sql admin_user@your.server.ip.address:/tmp/

# SSH into server
ssh admin_user@your.server.ip.address

# Import database (get credentials from .env file)
cd /srv/www/example.com/current
cat .env | grep DB_

# Import
mysql -u db_user -p database_name < /tmp/backup.sql

# Clean up
rm /tmp/backup.sql
```

### 7. Migrate Uploads

Transfer your uploads directory to the server's **shared** uploads directory. You have several options:

#### Option A: Using rsync (Recommended)

Best for large uploads directories - resumable and preserves permissions:

```bash
# From your local machine
rsync -avz --progress /path/to/backup/wp-content/uploads/ \
  admin_user@your.server.ip.address:/srv/www/example.com/shared/uploads/

# Set correct permissions on server
ssh admin_user@your.server.ip.address \
  "sudo chown -R web:www-data /srv/www/example.com/shared/uploads && \
   sudo chmod -R 775 /srv/www/example.com/shared/uploads"
```

#### Option B: Using SCP

For smaller uploads directories:

```bash
# From your local machine
scp -r /path/to/backup/wp-content/uploads/* \
  admin_user@your.server.ip.address:/tmp/uploads/

# SSH into server and move to correct location
ssh admin_user@your.server.ip.address

# Move uploads and set permissions
sudo mv /tmp/uploads/* /srv/www/example.com/shared/uploads/
sudo chown -R web:www-data /srv/www/example.com/shared/uploads
sudo chmod -R 775 /srv/www/example.com/shared/uploads
```

#### Option C: Using Trellis Backup Tools

If you want to use this repository's backup tools for ongoing sync:

```bash
# First, manually copy uploads using rsync or scp (Option A or B above)
# Then set up automated sync using the backup playbooks

# See: ../backup/README.md for details
ansible-playbook backup/trellis/files-pull.yml -e site=example.com -e env=production
```

**Verify uploads are accessible:**

```bash
# SSH into server
ssh admin_user@your.server.ip.address

# Check uploads directory
ls -la /srv/www/example.com/shared/uploads/

# Verify symlink works
ls -la /srv/www/example.com/current/web/app/uploads
# Should show it's a symlink to ../../../shared/uploads

# Test a sample file is accessible
ls -la /srv/www/example.com/shared/uploads/2024/
```

### Alternative: Using Automated Backup Playbooks (Workflow B)

If you're following **Workflow B** (Local-First Migration) and have set up your local development environment with the database and files already imported, you can use the automated backup playbooks instead of manual Steps 6-7.

#### Prerequisites for Using Backup Playbooks

1. Local development environment is running (`trellis vm start`)
2. Database and uploads are already in your local Bedrock installation
3. Production server is provisioned and deployed
4. Backup playbooks are available in this repository at `../backup/trellis/`

#### Push Database Using Playbook (Alternative to Step 6)

```bash
# From trellis directory
cd trellis

# Push database from development to production
ansible-playbook ../backup/trellis/database-push.yml -e site=example.com -e env=production
```

**What this playbook does automatically:**
- Exports database from local development environment
- Creates backup of production database (saved to `site/database_backup/`)
- Imports development database to production
- Performs search-replace for domain URLs (old domain → new domain)
- Performs search-replace for path conversions (wp-content → app) if needed
- Cleans up temporary files
- Provides detailed progress output

#### Push Files Using Playbook (Alternative to Step 7)

```bash
# From trellis directory
cd trellis

# Push uploads from development to production
ansible-playbook ../backup/trellis/files-push.yml -e site=example.com -e env=production
```

**What this playbook does automatically:**
- Syncs uploads directory from local to production
- Preserves file permissions and ownership
- Shows progress during transfer
- Includes confirmation prompt before overwriting
- Handles symlinks correctly
- Sets correct permissions on destination

#### When to Use the Backup Playbooks

**✅ Use backup playbooks when:**
- You have local development environment running
- Files and database are already in local Bedrock structure
- You want automated, repeatable process
- Migrating multiple sites (consistency is key)
- You need to test migrations before going live
- You want built-in safety features (backups, confirmations)

**❌ Don't use backup playbooks when:**
- Migrating directly from old server to production (use manual rsync/wp db import)
- Local development environment is not set up
- You need to customize the migration process significantly
- Source files are not yet in Bedrock structure locally

#### Benefits of Using Backup Playbooks for Migration

1. **Automated Path Conversion**: The database-push playbook can handle path conversions automatically
2. **Built-in Backups**: Production database is backed up before import
3. **Repeatable**: Easy to re-run if something goes wrong
4. **Consistent**: Same process for all three sites
5. **Time-Saving**: Faster than manual operations for multiple sites
6. **Error Handling**: Better error messages and rollback capabilities

For detailed documentation on the backup playbooks, see [backup/README.md](../backup/README.md).

### 8. Choose Your Path Migration Strategy

#### Strategy A: Full Bedrock Adoption (Recommended)

Update all file paths in the database to match Bedrock structure:

```bash
# SSH into Trellis server
cd /srv/www/example.com/current

# Preview theme path changes
wp search-replace '/wp-content/themes/' '/app/themes/' --all-tables --dry-run

# Apply theme path changes
wp search-replace '/wp-content/themes/' '/app/themes/' --all-tables

# Preview uploads path changes
wp search-replace 'https://example.com/wp-content/uploads/' 'https://example.com/app/uploads/' --all-tables --precise --dry-run

# Apply uploads path changes
wp search-replace 'https://example.com/wp-content/uploads/' 'https://example.com/app/uploads/' --all-tables --precise

# Also handle protocol-relative and non-HTTPS URLs
wp search-replace '//example.com/wp-content/uploads/' '//example.com/app/uploads/' --all-tables --precise
wp search-replace 'http://example.com/wp-content/uploads/' 'https://example.com/app/uploads/' --all-tables --precise

# Search for any remaining wp-content references
wp search-replace '/wp-content/plugins/' '/app/plugins/' --all-tables
```

**After path migration:**

```bash
# Flush caches and permalinks
wp cache flush
wp rewrite flush

# Regenerate thumbnails if needed
wp media regenerate --yes
```

#### Strategy B: Path Compatibility Mode

Keep existing paths by modifying Bedrock configuration:

**Edit `site/config/application.php`:**

```php
/**
 * Custom Content Directory
 * Keep wp-content paths for compatibility with existing database
 */
Config::define('CONTENT_DIR', '/wp-content');
Config::define('WP_CONTENT_DIR', $webroot_dir . Config::get('CONTENT_DIR'));
Config::define('WP_CONTENT_URL', Config::get('WP_HOME') . Config::get('CONTENT_DIR'));
```

**Adjust your directory structure:**

```bash
# On Trellis server, create symlinks or move directories
cd /srv/www/example.com/current/web

# Option 1: Rename app to wp-content (if you want actual directory)
mv app wp-content

# Option 2: Create symlink (more flexible)
ln -s app wp-content
```

**Important:** If using this approach, ensure your deployment process maintains this structure.

#### Strategy C: Hybrid Approach

Use Bedrock structure for new uploads but keep compatibility for existing ones:

**Edit `site/config/application.php`:**

```php
/**
 * Hybrid Content Directory
 * New uploads go to /app/uploads, but old paths still work
 */
Config::define('CONTENT_DIR', '/app');
Config::define('UPLOADS', 'uploads'); // Still uses /app/uploads for new

// Add rewrite rules in Nginx or .htaccess to redirect old paths
```

**Add to Trellis Nginx configuration** (`trellis/roles/wordpress-setup/templates/wordpress-site.conf.j2`):

```nginx
# Redirect old wp-content paths to new app paths
location ~ ^/wp-content/uploads/(.*)$ {
    return 301 /app/uploads/$1;
}

location ~ ^/wp-content/themes/(.*)$ {
    return 301 /app/themes/$1;
}
```

**Important**: If using Strategy B or C, you'll need to re-provision or reload Nginx:

```bash
# From trellis directory
cd trellis

# Re-provision with nginx tag only
trellis provision --tags nginx production

# Or just reload Nginx
ssh admin_user@your.server.ip.address "sudo systemctl reload nginx"
```

### 9. Test and Verify

Comprehensive testing checklist:

```bash
# Verify WordPress installation
wp core verify-checksums

# Check database
wp db check

# List active plugins
wp plugin list --status=active

# Check theme status
wp theme list

# Test search-replace was successful
wp db search 'wp-content/uploads' --all-tables

# Verify upload functionality
# Upload a test image via WordPress admin
```

**Manual Testing:**
- [ ] Homepage loads correctly
- [ ] All images display properly
- [ ] Theme styles are applied
- [ ] Navigation menus work
- [ ] Forms submit correctly
- [ ] Admin panel is accessible
- [ ] Plugins function as expected
- [ ] Custom post types display
- [ ] Search functionality works
- [ ] User login/logout works
- [ ] Media library displays all images
- [ ] Upload new media works

**Performance Testing:**
```bash
# Check site load time
curl -o /dev/null -s -w "Time: %{time_total}s\n" https://example.com

# Test HTTPS
curl -I https://example.com | grep "HTTP"

# Verify cache headers
curl -I https://example.com/app/uploads/2024/01/image.jpg | grep -i cache
```

### 10. DNS and Go-Live

When ready to go live:

1. **Lower TTL** on your current DNS records (24 hours before migration)
   ```
   example.com. 300 IN A old.server.ip
   ```

2. **Update DNS** to point to your new Trellis server
   ```
   example.com. 300 IN A new.server.ip
   ```

3. **Monitor** DNS propagation:
   ```bash
   # Check DNS propagation
   dig example.com +short

   # Check from multiple locations
   # Use: https://www.whatsmydns.net/
   ```

4. **Redirect old server** (optional, keep old hosting active for a few days):

   Add to old server's `.htaccess`:
   ```apache
   <IfModule mod_rewrite.c>
       RewriteEngine On
       RewriteCond %{HTTP_HOST} ^example\.com$ [OR]
       RewriteCond %{HTTP_HOST} ^www\.example\.com$
       RewriteRule ^(.*)$ https://example.com/$1 [R=301,L]
   </IfModule>
   ```

5. **SSL Certificate:**
   ```bash
   # Trellis handles this automatically with Let's Encrypt
   # Verify SSL is active:
   sudo certbot certificates
   ```

6. **Final verification:**
   ```bash
   # Check SSL score
   # Visit: https://www.ssllabs.com/ssltest/

   # Monitor server logs
   tail -f /var/log/nginx/error.log
   ```

## Time-Saving Tips for Multiple Sites

When migrating three sites to a single Trellis server, use these strategies to minimize time and maximize efficiency.

### 1. Batch Preparation Phase

Before starting any migrations, prepare all three sites at once:

**Checklist for all sites:**
- [ ] Download all databases from old hosting (export as `.sql` or `.sql.gz`)
- [ ] Download all file backups (themes, plugins, uploads) to organized local folders
- [ ] Document all active plugins for each site in a spreadsheet
- [ ] Generate all WordPress salts at once (visit https://roots.io/salts.html three times, save to text files)
- [ ] Create all three Git repositories on GitHub/GitLab
- [ ] Document any special configurations from old `wp-config.php` files

**Organize your downloads:**
```bash
# Create organized backup structure
mkdir -p ~/migrations/site1/{database,files}
mkdir -p ~/migrations/site2/{database,files}
mkdir -p ~/migrations/site3/{database,files}

# This organization saves time when you're ready to migrate each site
```

### 2. Use Descriptive Directory Names from Start

Instead of using generic `site/` directory, use descriptive names immediately to avoid confusion:

```bash
# For first site
trellis new example.com
cd example.com
mv site site-example

# Update trellis/group_vars/*/wordpress_sites.yml
# Change: local_path: ../site
# To:     local_path: ../site-example

# Then add second and third sites
composer create-project roots/bedrock site-clienttwo
composer create-project roots/bedrock site-clientthree
```

**Benefits:**
- No confusion about which site is which
- Easier to reference in commands
- Clear Git history
- Better for team collaboration

### 3. Configure All Sites Before First Provision

Add all three sites to `wordpress_sites.yml` before provisioning. This way:

- **Single provisioning run** sets up all three databases
- **All SSL certificates** created at once with Let's Encrypt
- **Nginx configured** for all sites simultaneously
- **Saves ~30 minutes** vs. provisioning three times

**Example `trellis/group_vars/production/wordpress_sites.yml`:**
```yaml
wordpress_sites:
  example.com:
    site_hosts:
      - canonical: example.com
    local_path: ../site-example
    repo: git@github.com:yourusername/trellis-multi.git
    repo_subtree_path: site-example
    # ... rest of config ...

  clienttwo.com:
    site_hosts:
      - canonical: clienttwo.com
    local_path: ../site-clienttwo
    repo: git@github.com:yourusername/trellis-multi.git
    repo_subtree_path: site-clienttwo
    # ... rest of config ...

  clientthree.com:
    site_hosts:
      - canonical: clientthree.com
    local_path: ../site-clientthree
    repo: git@github.com:yourusername/trellis-multi.git
    repo_subtree_path: site-clientthree
    # ... rest of config ...
```

Then run once:
```bash
trellis provision production
```

### 4. Parallel Operations

Take advantage of independent operations that can run simultaneously:

**While database is importing on Site 1:**
```bash
# In one terminal: Import database for site 1
ssh admin@server "cd /srv/www/example.com/current && wp db import /tmp/backup1.sql"

# In another terminal: Upload files for site 2
rsync -avz ~/migrations/site2/files/uploads/ admin@server:/srv/www/clienttwo.com/shared/uploads/

# In another terminal: Work on site 3 locally
cd ~/code/trellis-project/site-clientthree
# Copy theme and plugins
```

**While running search-replace on one site:**
- Deploy the next site
- Prepare the third site's uploads for transfer
- Run tests on a completed site

### 5. Create Reusable Scripts

Save time by scripting repetitive tasks:

**Script: `migrate-uploads.sh`**
```bash
#!/bin/bash
# Usage: ./migrate-uploads.sh site1 example.com

SITE_NAME=$1
DOMAIN=$2
LOCAL_UPLOADS=~/migrations/$SITE_NAME/files/uploads
SERVER_PATH=/srv/www/$DOMAIN/shared/uploads

echo "Migrating uploads for $DOMAIN..."
rsync -avz --progress $LOCAL_UPLOADS/ admin@your.server.ip:$SERVER_PATH/

echo "Setting permissions..."
ssh admin@your.server.ip "sudo chown -R web:www-data $SERVER_PATH && sudo chmod -R 775 $SERVER_PATH"

echo "Done!"
```

**Script: `import-database.sh`**
```bash
#!/bin/bash
# Usage: ./import-database.sh site1 example.com

SITE_NAME=$1
DOMAIN=$2
LOCAL_DB=~/migrations/$SITE_NAME/database/backup.sql

echo "Uploading database for $DOMAIN..."
scp $LOCAL_DB admin@your.server.ip:/tmp/backup-$SITE_NAME.sql

echo "Importing database..."
ssh admin@your.server.ip "cd /srv/www/$DOMAIN/current && wp db import /tmp/backup-$SITE_NAME.sql && rm /tmp/backup-$SITE_NAME.sql"

echo "Done!"
```

### 6. Use Workflow B for Maximum Efficiency

For three sites, **Workflow B** (Local-First Migration) with backup playbooks is most efficient:

**Advantages for multiple sites:**
1. Test each migration locally before production
2. Use automated playbooks for consistency
3. Easy to repeat if something goes wrong
4. Can work on next site while previous deploys

**Timeline for three sites using Workflow B:**
- **Day 1 (4-5 hours):** Site 1 - Full setup, local test, push to production
- **Day 2 (3 hours):** Site 2 - Faster since server/process established
- **Day 3 (2.5 hours):** Site 3 - Fastest, everything is familiar

**Total: 9-10.5 hours** vs. 12-15 hours with direct migration

### 7. Maintain a Migration Checklist

Track progress across all sites with a simple checklist:

```markdown
## Migration Progress Tracker

### Site 1: example.com
- [x] Backups downloaded
- [x] Bedrock created (site-example)
- [x] Theme/plugins copied
- [x] Deployed to production
- [x] Database migrated
- [x] Uploads synced
- [x] Paths converted
- [x] Tested
- [x] DNS updated

### Site 2: clienttwo.com
- [x] Backups downloaded
- [x] Bedrock created (site-clienttwo)
- [ ] Theme/plugins copied
- [ ] Deployed to production
...
```

### 8. Common Configuration Across Sites

If all three sites share similar requirements, create templates:

**Template: Search-replace commands**
```bash
# Save as search-replace-template.sh
# Update domain for each site

DOMAIN=$1
wp search-replace '/wp-content/themes/' '/app/themes/' --all-tables
wp search-replace '/wp-content/plugins/' '/app/plugins/' --all-tables
wp search-replace "https://$DOMAIN/wp-content/uploads/" "https://$DOMAIN/app/uploads/" --all-tables --precise
wp search-replace "http://$DOMAIN/wp-content/uploads/" "https://$DOMAIN/app/uploads/" --all-tables --precise
wp cache flush
wp rewrite flush
```

**Usage:**
```bash
# Run on each site
ssh admin@server "cd /srv/www/example.com/current && bash" < search-replace-template.sh example.com
```

### Summary: Optimal Multi-Site Migration Strategy

1. ✅ **Batch prepare** all three sites upfront (1 hour)
2. ✅ **Configure all sites** in Trellis before provisioning (30 mins)
3. ✅ **Provision once** for all three sites (15 mins)
4. ✅ **Use Workflow B** with backup playbooks (most efficient)
5. ✅ **Run operations in parallel** where possible
6. ✅ **Create reusable scripts** for repetitive tasks
7. ✅ **Track progress** with checklist

**Expected timeline for three sites: 8-10 hours total** (vs. 12-15 hours without optimization)

## Managing Multiple Sites on One Server

One of Trellis's strengths is the ability to host **multiple WordPress sites on a single server**. This is common for agencies or when consolidating multiple client sites.

### Important: Directory Structure for Multiple Sites

When you use `trellis new example.com`, it creates a directory structure with a `site/` folder for your Bedrock installation. However, when managing **multiple sites on the same server**, you should:

1. **Use descriptive directory names** instead of generic `site/`
2. **Each site gets its own Bedrock installation** in the Trellis project
3. **All sites share the same Trellis configuration**

### Scenario 1: First Site on Server (Using trellis new)

For your first site, you can use `trellis new`:

```bash
cd ~/code

# This creates the Trellis project with default 'site/' directory
trellis new imagewize.com
cd imagewize.com

# Your structure:
# imagewize.com/
# ├── trellis/
# └── site/         # Bedrock for imagewize.com
```

**However**, if you know you'll be adding more sites later, it's better to rename `site/` immediately:

```bash
# Rename site to something descriptive
mv site site-imagewize

# Update trellis/group_vars/*/wordpress_sites.yml
# Change: local_path: ../site
# To:     local_path: ../site-imagewize
```

### Scenario 2: Adding a Second Site to Existing Trellis

When you need to add a second site to your existing Trellis server:

#### Step 1: Create New Bedrock Installation

Use Composer to create a new Bedrock installation with a descriptive name:

```bash
# Navigate to your Trellis project root
cd ~/code/imagewize.com  # Your existing Trellis project

# Create new Bedrock installation for second site
composer create-project roots/bedrock site-clientname

# Or for a specific site
composer create-project roots/bedrock site-name
```

This creates:
```
imagewize.com/
├── trellis/
├── site-imagewize/    # First site
└── site-name/ # Second site
```

#### Step 2: Configure the New Site in Trellis

**Edit development configuration** - `trellis/group_vars/development/wordpress_sites.yml`:

```yaml
wordpress_sites:
  # First site
  imagewize.com:
    site_hosts:
      - canonical: imagewize.test
    local_path: ../site-imagewize
    # ... other settings ...

  # Second site (NEW)
  jasperfrumau.com:
    site_hosts:
      - canonical: jasperfrumau.test
    local_path: ../site-jasperfrumau  # Points to new Bedrock directory
    admin_email: admin@jasperfrumau.com
    multisite:
      enabled: false
    ssl:
      enabled: false  # Development doesn't need SSL
    cache:
      enabled: false
```

**Edit production configuration** - `trellis/group_vars/production/wordpress_sites.yml`:

```yaml
wordpress_sites:
  # First site
  imagewize.com:
    site_hosts:
      - canonical: imagewize.com
        redirects:
          - www.imagewize.com
    local_path: ../site-imagewize
    repo: git@github.com:yourusername/imagewize.com.git
    repo_subtree_path: site-imagewize
    branch: main
    multisite:
      enabled: false
    ssl:
      enabled: true
      provider: letsencrypt
    cache:
      enabled: true

  # Second site (NEW)
  jasperfrumau.com:
    site_hosts:
      - canonical: jasperfrumau.com
        redirects:
          - www.jasperfrumau.com
    local_path: ../site-jasperfrumau
    repo: git@github.com:yourusername/imagewize.com.git  # Same repo!
    repo_subtree_path: site-jasperfrumau  # Different path in repo
    branch: main
    multisite:
      enabled: false
    ssl:
      enabled: true
      provider: letsencrypt
    cache:
      enabled: true
```

**Edit vault for both environments** - `trellis/group_vars/*/vault.yml`:

```bash
# Edit development vault
cd trellis
trellis vault edit development

# Edit production vault
trellis vault edit production
```

Add configuration for the new site:

```yaml
vault_wordpress_sites:
  # First site
  imagewize.com:
    env:
      db_password: "secure_password_1"
      # ... salts ...

  # Second site (NEW)
  jasperfrumau.com:
    env:
      db_password: "secure_password_2"  # Different password!
      # Generate new salts at: https://roots.io/salts.html
      auth_key: "generateme"
      secure_auth_key: "generateme"
      logged_in_key: "generateme"
      nonce_key: "generateme"
      auth_salt: "generateme"
      secure_auth_salt: "generateme"
      logged_in_salt: "generateme"
      nonce_salt: "generateme"
```

#### Step 3: Add New Site to Git Repository

Since both sites share the same Trellis configuration, they should be in the same Git repository:

```bash
# From project root
cd ~/code/imagewize.com

# Add new Bedrock installation
git add site-jasperfrumau/

# Commit
git commit -m "Add jasperfrumau.com site"

# Push
git push origin main
```

#### Step 4: Re-Provision Server (REQUIRED for New Sites)

**IMPORTANT:** When adding a new site to an existing server, you **MUST re-provision** to create the necessary infrastructure for the new site:

```bash
cd trellis

# Re-provision production to create infrastructure for new site
trellis provision production
```

**What this does for the new site:**
- ✅ Creates new MySQL database (`jasperfrumau_production`)
- ✅ Creates new database user with credentials from vault
- ✅ Generates Nginx virtual host configuration (`/etc/nginx/sites-available/jasperfrumau.com.conf`)
- ✅ Requests and installs Let's Encrypt SSL certificate for new domain
- ✅ Creates base directory structure (`/srv/www/jasperfrumau.com/`)
- ✅ Updates firewall rules if needed

**Without re-provisioning:**
- ❌ Database won't exist → deployment fails
- ❌ No Nginx config → site shows 502 Bad Gateway
- ❌ No SSL certificate → HTTPS won't work
- ❌ No directory structure → deployment fails

**Alternative (Advanced):** If you only changed Nginx-related settings and know the database already exists:
```bash
# Only update Nginx configuration (faster, but less safe)
ansible-playbook server.yml -e env=production --tags nginx
```

**Best practice:** Always use full `trellis provision production` when adding a new site. It's safer and ensures everything is configured correctly.

#### Step 5: Deploy the New Site

```bash
cd trellis

# Deploy the new site
trellis deploy production jasperfrumau.com

# Or deploy all sites
trellis deploy production
```

#### Step 6: Migrate the Second Site's Data

Follow the same migration steps as the first site:

1. **Import database** to the new site:
   ```bash
   ssh admin_user@your.server.ip.address
   cd /srv/www/jasperfrumau.com/current
   wp db import /path/to/backup.sql
   ```

2. **Transfer uploads**:
   ```bash
   rsync -avz --progress /path/to/backup/wp-content/uploads/ \
     admin_user@your.server.ip.address:/srv/www/jasperfrumau.com/shared/uploads/
   ```

3. **Update paths** (choose your strategy from main guide)

### Directory Structure Example

Here's what a multi-site Trellis setup looks like:

```
imagewize.com/                    # Project root (Git repository)
├── .git/
├── trellis/                      # Shared Trellis configuration
│   ├── group_vars/
│   │   ├── all/
│   │   ├── development/
│   │   │   ├── wordpress_sites.yml    # Both sites configured here
│   │   │   └── vault.yml              # Both sites' dev secrets
│   │   └── production/
│   │       ├── wordpress_sites.yml    # Both sites configured here
│   │       └── vault.yml              # Both sites' prod secrets
│   └── hosts/
│       ├── development
│       └── production              # Same server IP for both sites
├── site-imagewize/                # First site (Bedrock)
│   ├── composer.json
│   ├── config/
│   └── web/
│       └── app/
│           ├── themes/
│           └── plugins/
└── site-jasperfrumau/             # Second site (Bedrock)
    ├── composer.json
    ├── config/
    └── web/
        └── app/
            ├── themes/
            └── plugins/
```

### On the Server

Each site gets its own directory structure:

```
/srv/www/
├── imagewize.com/
│   ├── current -> releases/20241023...
│   ├── releases/
│   │   └── 20241023.../
│   └── shared/
│       └── uploads/
└── jasperfrumau.com/
    ├── current -> releases/20241023...
    ├── releases/
    │   └── 20241023.../
    └── shared/
        └── uploads/
```

### Best Practices for Multiple Sites

1. **Use descriptive directory names**: `site-clientname` instead of `site/`, `site1/`, `site2/`

2. **Separate databases**: Each site gets its own MySQL database automatically

3. **Separate database passwords**: Use different passwords in vault for each site

4. **Same server, same Trellis**: All sites on the same server share one Trellis configuration

5. **One Git repository**: Keep all sites and Trellis in the same repository using `repo_subtree_path`

6. **Consider resource limits**: Monitor server resources (RAM, CPU) as you add more sites

7. **SSL certificates**: Let's Encrypt handles multiple domains automatically

### Common Commands for Multiple Sites

```bash
# Deploy specific site
trellis deploy production imagewize.com

# Deploy all sites
trellis deploy production

# Re-provision to update all sites
trellis provision production

# SSH and access specific site
ssh admin_user@your.server.ip.address
cd /srv/www/imagewize.com/current

# WP-CLI for specific site
wp --path=/srv/www/imagewize.com/current/web plugin list
wp --path=/srv/www/jasperfrumau.com/current/web plugin list
```

### When NOT to Use Multiple Sites on One Server

Consider separate servers if:
- Sites have vastly different traffic patterns
- Different PHP version requirements
- Regulatory/security isolation requirements
- One site is mission-critical and needs dedicated resources

## Common Pitfalls When Migrating Multiple Sites

Avoid these common mistakes when migrating multiple WordPress sites to a single Trellis server.

### 1. Forgetting to Update `local_path` for Each Site

**Problem:** All sites point to `../site` instead of unique paths like `../site-example`, `../site-clienttwo`.

**Symptom:** Deployments fail or deploy the wrong site's code.

**Solution:** Always verify unique paths in `wordpress_sites.yml`:

```yaml
wordpress_sites:
  example.com:
    local_path: ../site-example  # ✅ Unique path
    # ...

  clienttwo.com:
    local_path: ../site-clienttwo  # ✅ Unique path
    # ...
```

**How to check:**
```bash
# From trellis directory
grep -A 5 "local_path" group_vars/production/wordpress_sites.yml
```

### 2. Reusing Database Passwords Across Sites

**Problem:** Copy-pasting vault configuration without changing passwords for each site.

**Security Risk:** If one site is compromised, all sites are at risk.

**Solution:** Generate unique passwords for each site:

```bash
# Generate secure password for each site
openssl rand -base64 32

# Edit vault and paste unique password for each site
trellis vault edit production
```

**Vault structure should look like:**
```yaml
vault_wordpress_sites:
  example.com:
    env:
      db_password: "unique_password_1_here"  # Different!
      # ...

  clienttwo.com:
    env:
      db_password: "unique_password_2_here"  # Different!
      # ...
```

### 3. Not Testing Path Conversions Thoroughly

**Problem:** Assuming search-replace worked without verification.

**Symptom:** Some images or assets still have old paths, causing 404 errors.

**Solution:** Always verify after running search-replace:

```bash
# SSH into server
cd /srv/www/example.com/current

# Check for any remaining wp-content references
wp db search 'wp-content/uploads' --all-tables
wp db search 'wp-content/themes' --all-tables
wp db search 'wp-content/plugins' --all-tables

# Should return no results if conversion was successful
```

**If you find remaining references:**
```bash
# Run additional search-replace for specific cases
wp search-replace '//example.com/wp-content/' '//example.com/app/' --all-tables --precise
```

### 4. Skipping DNS Propagation Time

**Problem:** Going live immediately after DNS change, causing confusion when some users see old site and others see new site.

**Impact:** Mixed analytics, confused users, potential lost transactions.

**Solution:**

```bash
# 24-48 hours BEFORE migration:
# Lower TTL on DNS records (via your DNS provider)
# Change from 3600 (1 hour) to 300 (5 minutes)

# After DNS update:
# Check DNS propagation
dig example.com +short

# Check from multiple global locations
# Use: https://www.whatsmydns.net/

# Keep old server running for 24-48 hours as fallback
```

### 5. Incorrect File Permissions on Uploads

**Problem:** Uploads directory has wrong owner or permissions after transfer.

**Symptom:** Can't upload new media, or existing images don't display.

**Solution:** Always set correct permissions after file transfer:

```bash
# After rsync/scp of uploads
ssh admin@server

# Set ownership (web:www-data is the Trellis default)
sudo chown -R web:www-data /srv/www/example.com/shared/uploads

# Set permissions (775 allows web server to write)
sudo chmod -R 775 /srv/www/example.com/shared/uploads

# Verify
ls -la /srv/www/example.com/shared/uploads
```

### 6. Not Updating All Environment Files

**Problem:** Updating `production/wordpress_sites.yml` but forgetting `development/wordpress_sites.yml`.

**Symptom:** Local development breaks or uses wrong configuration.

**Solution:** Always update both environments:

```bash
# Update both files when adding a new site
trellis/group_vars/development/wordpress_sites.yml
trellis/group_vars/production/wordpress_sites.yml

# And both vault files
trellis vault edit development
trellis vault edit production
```

### 7. Mixing Up `repo_subtree_path` Values

**Problem:** Multiple sites pointing to same subtree path in Git repo.

**Symptom:** Deployment pulls wrong code for a site.

**Solution:** Ensure each site has unique `repo_subtree_path`:

```yaml
wordpress_sites:
  example.com:
    repo: git@github.com:user/trellis-multi.git
    repo_subtree_path: site-example  # ✅ Unique

  clienttwo.com:
    repo: git@github.com:user/trellis-multi.git
    repo_subtree_path: site-clienttwo  # ✅ Unique
```

### 8. Forgetting to Re-Provision After Adding New Site

**Problem:** Adding second or third site to config but not re-provisioning server before deployment.

**Symptom:**
- Deployment fails with database connection errors
- Site shows 502 Bad Gateway (no Nginx config)
- SSL certificate missing or invalid
- Directory structure `/srv/www/newsitedomain.com/` doesn't exist

**Why this happens:** When you add a new site to `wordpress_sites.yml`, Trellis doesn't automatically create the infrastructure. You must re-provision to:
- Create MySQL database for the new site
- Generate Nginx virtual host configuration
- Request and install Let's Encrypt SSL certificate
- Create base directory structure

**Solution:** Always re-provision after adding sites to configuration:

```bash
cd trellis

# STEP 1: Add new site to wordpress_sites.yml
# STEP 2: Re-provision to create all infrastructure
trellis provision production

# STEP 3: Now you can deploy the new site
trellis deploy production example.com

# Alternative: Just update Nginx if that's all that changed
# (Use this only if you know the database and other components exist)
ansible-playbook server.yml -e env=production --tags nginx
```

**Best Practice for Multiple Sites:**
Configure all three sites in `wordpress_sites.yml` BEFORE the first provision. This way you provision once and create infrastructure for all sites simultaneously.

### 9. Using Same WordPress Salts Across Sites

**Problem:** Copy-pasting salts from first site to second and third sites.

**Security Risk:** Reduces security isolation between sites.

**Solution:** Generate unique salts for each site:

```bash
# Visit https://roots.io/salts.html three times
# Save each set of salts separately
# Paste unique salts into vault for each site

trellis vault edit production
```

### 10. Not Testing Locally First (When Using Workflow B)

**Problem:** Pushing directly to production without local testing.

**Risk:** Database issues, path problems, or plugin conflicts discovered only in production.

**Solution:** Always test in local development first:

```bash
# Start local VM
trellis vm start

# Import database locally
cd ~/code/trellis-project/site-example
wp db import ~/migrations/site1/database/backup.sql

# Test at https://example.test
# Fix any issues locally before pushing to production
```

### 11. Incorrect Branch Names in Configuration

**Problem:** Configuration uses `branch: main` but Git repo uses `master` (or vice versa).

**Symptom:** Deployment fails with "branch not found" error.

**Solution:** Verify branch name matches your Git repository:

```bash
# Check what branch your repo uses
cd ~/code/trellis-project
git branch

# Update wordpress_sites.yml to match
wordpress_sites:
  example.com:
    branch: main  # or 'master' - must match your repo!
```

### 12. Overwriting Production Database Accidentally

**Problem:** Running database-push playbook and forgetting it will overwrite production.

**Risk:** Loss of production data (orders, users, posts created since migration).

**Solution:** Always use the backup features:

```bash
# The database-push playbook includes automatic backup
# But verify backup exists before running:

# Manual backup before push
ssh admin@server "cd /srv/www/example.com/current && wp db export /tmp/pre-push-backup.sql"

# Then run push
ansible-playbook database-push.yml -e site=example.com -e env=production

# Playbook will create backup automatically in site/database_backup/
```

### Prevention Checklist

Before migrating sites 2 and 3, verify these for each site:

- [ ] Unique `local_path` in `wordpress_sites.yml`
- [ ] Unique database password in vault
- [ ] Unique WordPress salts in vault
- [ ] Unique `repo_subtree_path` (if using same Git repo)
- [ ] Correct branch name (`main` vs `master`)
- [ ] Both development and production configs updated
- [ ] File permissions set correctly after upload
- [ ] Path conversions verified with `wp db search`
- [ ] DNS TTL lowered 24 hours before switching
- [ ] Local testing completed (if using Workflow B)

## Troubleshooting

### Issue: Images Not Displaying

**Symptoms:** Broken image links, 404 errors on media files

**Solutions:**

```bash
# 1. Check upload directory permissions
ls -la /srv/www/example.com/shared/uploads/
sudo chown -R web:www-data /srv/www/example.com/shared/uploads
sudo chmod -R 775 /srv/www/example.com/shared/uploads

# 2. Verify symlink is correct
ls -la /srv/www/example.com/current/web/app/
# Should show: uploads -> ../../../shared/uploads

# 3. Check for mixed path references
wp db search 'wp-content/uploads' --all-tables

# 4. Regenerate thumbnails
wp media regenerate --yes

# 5. Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Issue: White Screen of Death (WSOD)

**Symptoms:** Blank white screen, no error messages

**Solutions:**

```bash
# 1. Enable debug mode
# Edit site/config/environments/production.php
Config::define('WP_DEBUG', true);
Config::define('WP_DEBUG_LOG', true);
Config::define('WP_DEBUG_DISPLAY', false);

# 2. Check PHP error logs
sudo tail -f /var/log/php8.2-fpm.log

# 3. Verify file permissions
sudo chown -R web:www-data /srv/www/example.com/current
sudo chmod -R 755 /srv/www/example.com/current

# 4. Check for plugin conflicts
wp plugin deactivate --all
wp plugin activate plugin-name  # Activate one by one
```

### Issue: Database Connection Errors

**Symptoms:** "Error establishing database connection"

**Solutions:**

```bash
# 1. Verify database credentials
cat site/.env | grep DB_

# 2. Check database exists
mysql -u db_user -p -e "SHOW DATABASES;"

# 3. Test database connection
wp db check

# 4. Verify MariaDB is running
sudo systemctl status mariadb

# 5. Check database user permissions
mysql -u root -p
# Then in MySQL:
SELECT user, host FROM mysql.user;
SHOW GRANTS FOR 'db_user'@'localhost';
```

### Issue: Permalinks Not Working (404 Errors)

**Symptoms:** Homepage works, but all other pages show 404

**Solutions:**

```bash
# 1. Flush rewrite rules
wp rewrite flush

# 2. Regenerate .htaccess (if using Apache)
wp rewrite flush --hard

# 3. Check Nginx configuration
sudo nginx -t

# 4. Verify WordPress .htaccess rules are in place
cat /srv/www/example.com/current/web/.htaccess

# 5. Restart Nginx
sudo systemctl restart nginx
```

### Issue: Plugin or Theme Compatibility

**Symptoms:** Plugins not working, theme breaking

**Solutions:**

```bash
# 1. Check for hardcoded paths in theme
grep -r "wp-content" /srv/www/example.com/current/web/app/themes/your-theme/

# 2. Search for ABSPATH usage
grep -r "ABSPATH" /srv/www/example.com/current/web/app/themes/your-theme/

# 3. Update plugins to latest versions
wp plugin update --all

# 4. Check plugin compatibility with PHP version
wp plugin list

# 5. Review plugin-specific logs
wp plugin deactivate problematic-plugin
# Check if issue resolves
```

### Issue: Slow Performance After Migration

**Symptoms:** Site loads slowly compared to old server

**Solutions:**

```bash
# 1. Enable object caching (Redis)
# Edit trellis/group_vars/production/wordpress_sites.yml
cache:
  enabled: true

# 2. Install Redis plugin
composer require wpackagist-plugin/redis-cache

# 3. Check query monitor for slow queries
composer require wpackagist-plugin/query-monitor --dev

# 4. Optimize database
wp db optimize

# 5. Check server resources
htop
free -h
df -h

# 6. Enable FastCGI cache in Nginx (already in Trellis)
# Verify it's working:
curl -I https://example.com | grep "X-FastCGI-Cache"
```

### Issue: Mixed Content Warnings (HTTP/HTTPS)

**Symptoms:** Browser shows "not secure" warnings, mixed content errors

**Solutions:**

```bash
# 1. Update all URLs to HTTPS
wp search-replace 'http://example.com' 'https://example.com' --all-tables --dry-run
wp search-replace 'http://example.com' 'https://example.com' --all-tables

# 2. Check for hardcoded HTTP URLs in theme
grep -r "http://" /srv/www/example.com/current/web/app/themes/your-theme/

# 3. Install SSL insecure content fixer plugin (temporary)
wp plugin install ssl-insecure-content-fixer --activate

# 4. Verify SSL certificate
sudo certbot certificates

# 5. Check browser console for specific mixed content URLs
# Fix them individually in database or theme files
```

## Post-Migration Optimization

After successful migration, consider these optimizations:

### 1. Set Up Backups

```bash
# Use the backup tools in this repository
# See: ../backup/README.md

# Set up automated database backups
ansible-playbook backup/trellis/database-backup.yml -e site=example.com -e env=production

# Set up automated file backups
ansible-playbook backup/trellis/files-backup.yml -e site=example.com -e env=production
```

### 2. Enable Redis Object Caching

```bash
# Install Redis plugin
composer require wpackagist-plugin/redis-cache

# Activate and enable
wp plugin activate redis-cache
wp redis enable
```

### 3. Configure Browser Caching

See the [Browser Caching Guide](../browser-caching/README.md) in this repository.

### 4. Optimize Images

See the [Image Optimization Guide](../image-optimization/README.md) for WebP/AVIF support.

### 5. Set Up Monitoring

```bash
# Install monitoring tools
composer require wpackagist-plugin/query-monitor --dev

# Set up server monitoring
# Consider: New Relic, Datadog, or Prometheus
```

### 6. Security Hardening

```bash
# Install security plugin
composer require wpackagist-plugin/wordfence

# Disable file editing in WordPress admin
# Add to site/config/application.php:
Config::define('DISALLOW_FILE_EDIT', true);

# Set up fail2ban for SSH protection
sudo apt install fail2ban
```

### 7. Performance Monitoring

```bash
# Install performance monitoring
wp plugin install query-monitor --activate

# Check page load times
curl -o /dev/null -s -w "Total time: %{time_total}s\n" https://example.com

# Use tools like:
# - GTmetrix: https://gtmetrix.com/
# - Google PageSpeed Insights: https://pagespeed.web.dev/
# - Pingdom: https://tools.pingdom.com/
```

### 8. Regular Maintenance Schedule

Create a maintenance schedule:

```bash
# Weekly tasks
- Review error logs
- Update plugins and themes
- Check site backups
- Monitor site performance

# Monthly tasks
- Security audit
- Database optimization
- Review and update dependencies
- Check for WordPress core updates

# Quarterly tasks
- Full backup verification
- Disaster recovery drill
- Performance audit
- Security penetration testing
```

## Additional Resources

- [Trellis Documentation](https://roots.io/trellis/docs/)
- [Bedrock Documentation](https://roots.io/bedrock/docs/)
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
- [Roots Discourse Community](https://discourse.roots.io/)

## Need More Help?

- Review the main [Migration Guide](README.md) for other migration scenarios
- Check the [Backup Tools](../backup/README.md) for data management
- See [Provisioning Guide](../provision/README.md) for server setup help
