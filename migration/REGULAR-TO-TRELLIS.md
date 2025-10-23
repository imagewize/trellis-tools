# Migrating from Regular WordPress to Trellis with Bedrock

This guide covers the complete process of migrating a standard WordPress installation (from shared hosting, Plesk, cPanel, etc.) to a [Roots Trellis](https://roots.io/trellis/) server running [Bedrock](https://roots.io/bedrock/). This is particularly useful when you need to modernize your WordPress infrastructure while maintaining a non-Sage theme.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Migration Approaches](#migration-approaches)
- [Pre-Migration Checklist](#pre-migration-checklist)
- [Step-by-Step Migration Process](#step-by-step-migration-process)
  - [Migration Workflow Overview](#migration-workflow-overview)
  - [1. Set Up Trellis and Bedrock Locally](#1-set-up-trellis-and-bedrock-locally)
  - [2. Provision Your Server](#2-provision-your-server)
  - [3. Prepare Your Existing WordPress Site](#3-prepare-your-existing-wordpress-site)
  - [4. Transfer Theme and Plugins to Local Bedrock](#4-transfer-theme-and-plugins-to-local-bedrock)
  - [5. Deploy Bedrock to Server](#5-deploy-bedrock-to-server)
  - [6. Migrate the Database](#6-migrate-the-database)
  - [7. Migrate Uploads](#7-migrate-uploads)
  - [8. Choose Your Path Migration Strategy](#8-choose-your-path-migration-strategy)
  - [9. Test and Verify](#9-test-and-verify)
  - [10. DNS and Go-Live](#10-dns-and-go-live)
- [Managing Multiple Sites on One Server](#managing-multiple-sites-on-one-server)
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

```bash
# From trellis directory
cd trellis

# Deploy to production
trellis deploy production
```

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

#### Step 4: Re-Provision Server (If Needed)

If this is a **brand new site** on an **existing server**, you typically only need to re-provision to update Nginx configurations:

```bash
cd trellis

# Re-provision production (updates Nginx, creates new database, etc.)
trellis provision production

# Or just update Nginx configuration
ansible-playbook server.yml -e env=production --tags nginx
```

**Note**: If the server is already provisioned and you just need to add the new site:
- Trellis will create the new database
- Configure new Nginx server blocks
- Set up SSL certificates for the new domain

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
