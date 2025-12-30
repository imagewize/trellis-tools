# Trellis Project Setup Guide

Guide for cloning and setting up an existing Trellis/Bedrock WordPress project on a Mac.

**Prerequisites:** Your machine must already be configured for Trellis development. If not, see [NEW-MACHINE.md](NEW-MACHINE.md) first.

## Table of Contents

- [Clone Repository](#clone-repository)
- [Install Dependencies](#install-dependencies)
- [Configure Environment Files](#configure-environment-files)
- [Start and Provision Trellis VM](#start-and-provision-trellis-vm)
- [Database and Files Setup](#database-and-files-setup)
- [Theme Development](#theme-development)
- [Production Access](#production-access)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)
- [Verification Checklist](#verification-checklist)

## Clone Repository

```bash
cd ~/code
git clone git@github.com:YOUR_ORG/your-project.git
cd your-project
```

**Repository structure** for Roots.io projects:
```
your-project/
├── site/                    # Bedrock WordPress installation
│   ├── composer.json       # PHP dependencies
│   ├── config/             # Environment configs
│   └── web/
│       ├── app/
│       │   └── themes/your-theme/  # Sage theme
│       └── wp/             # WordPress core (managed by Composer)
└── trellis/                # Server provisioning and deployment
    ├── group_vars/         # Ansible configuration
    └── trellis.yml         # Trellis configuration
```

## Install Dependencies

### 1. Install PHP Dependencies (Bedrock)

Before running `composer install`, check if your project requires any special authentication (e.g., for premium plugins).

#### Example: ACF Pro Authentication

If your project uses Advanced Custom Fields Pro:

```bash
cd site

# Create auth.json with ACF Pro license key
cat > auth.json << 'EOF'
{
  "http-basic": {
    "connect.advancedcustomfields.com": {
      "username": "YOUR_ACF_LICENSE_KEY",
      "password": "http://YOUR_SITE_URL"
    }
  }
}
EOF
```

**Security note:** `auth.json` should be in `.gitignore` and never committed.

#### Install Composer Packages

```bash
# In site directory
composer install
```

**What this installs:**
- WordPress core
- WordPress plugins (via Composer)
- Premium plugins (if configured)
- Bedrock boilerplate dependencies

**Output:** Creates `site/vendor/` directory (~100MB)

### 2. Install Theme Dependencies

```bash
cd web/app/themes/your-theme

# Using pnpm (recommended)
pnpm install

# OR using npm
npm install
```

**What this installs:**
- Vite (build tool)
- CSS framework (Tailwind, etc.)
- Theme framework dependencies (Sage, etc.)

**Output:** Creates `node_modules/` directory (~400MB)

## Configure Environment Files

### Development Environment (.env)

Create `.env` file in `site/` directory:

```bash
cd site
cp .env.example .env
```

Edit `.env` with your local development settings:

```env
DB_NAME='your_project_dev'
DB_USER='example_dbuser'
DB_PASSWORD='example_dbpassword'

# Optional: WordPress admin user (created during provisioning)
WP_ENV='development'
WP_HOME='https://yourproject.test'
WP_SITEURL="${WP_HOME}/wp"

# Generate salts at: https://roots.io/salts.html
AUTH_KEY='generateme'
SECURE_AUTH_KEY='generateme'
# ... (other salts)
```

### Trellis Configuration

Check `trellis/group_vars/development/wordpress_sites.yml`:

```yaml
wordpress_sites:
  yourproject.test:
    site_hosts:
      - canonical: yourproject.test
    local_path: ../site  # Path to Bedrock installation
    admin_email: admin@yourproject.test
    multisite:
      enabled: false
    ssl:
      enabled: true
      provider: self-signed
    cache:
      enabled: false
```

**Note:** Most projects have this pre-configured. Only edit if customizing your local setup.

## Start and Provision Trellis VM

### 1. Initialize Trellis

**IMPORTANT:** Run this before starting the VM for the first time.

```bash
cd trellis
trellis init
```

**What this does:**
- Creates Python virtual environment (`.trellis/virtualenv/`)
- Installs Ansible and dependencies
- Prepares project for Trellis CLI management

**First-time setup:** ~2-5 minutes (downloading and installing Python packages)

**Expected output:**
```
Initializing project...

[✓] Created virtualenv (/path/to/project/trellis/.trellis/virtualenv)
[✓] Ensure pip is up to date
[✓] Dependencies installed
```

**Note:** You may see verbose pip output if installation takes longer than expected. This is normal.

### 2. Copy Vault Password

**IMPORTANT:** Required for provisioning. The vault password decrypts sensitive configuration (database passwords, etc.).

If you're setting up an existing project on a new machine, copy the `.vault_pass` file from your existing development machine:

```bash
# On your existing machine
cat /path/to/project/trellis/.vault_pass

# On your new machine
cd /Users/j/code/imagewize.com/trellis
echo "PASTE_PASSWORD_HERE" > .vault_pass
chmod 600 .vault_pass
```

**Security notes:**
- `.vault_pass` should be in `.gitignore` (never commit it!)
- Each team member needs this file for provisioning
- Share securely (1Password, encrypted message, etc.)

**Alternative (new projects only):** If starting fresh, you can create a new vault password:
```bash
echo "$(openssl rand -base64 32)" > trellis/.vault_pass
chmod 600 trellis/.vault_pass
```
Then you'll need to re-encrypt vault files with the new password.

### 3. Start Trellis VM

```bash
cd trellis
trellis vm start
```

**What this does:**
- Creates a Lima VM with Ubuntu 24.04
- Mounts project directory to VM
- Sets up bidirectional file sync
- Automatically adds site hosts to `/etc/hosts`

**First-time setup:** ~2-5 minutes

**Expected output:**
```
Starting VM...
VM started successfully.
VM IP: 192.168.56.5
```

### 4. Verify /etc/hosts Entry

Trellis CLI automatically adds your site to `/etc/hosts`:

```bash
grep yourproject.test /etc/hosts
```

**Expected output:** `192.168.56.5  yourproject.test`

**If missing:** Add manually:
```bash
sudo sh -c 'echo "192.168.56.5  yourproject.test" >> /etc/hosts'
```

### 5. Provision Development Environment

```bash
# In trellis directory
trellis provision development
```

**What this does:**
- Installs LEMP stack (Linux, Nginx, MySQL, PHP)
- Configures Nginx virtual hosts
- Sets up PHP-FPM
- Creates MySQL database
- Installs WordPress via WP-CLI
- Configures SSL certificates (self-signed for local)

**First-time provisioning:** ~10-15 minutes

**Expected output:**
```
PLAY RECAP ***************************************************************
192.168.56.5 : ok=XXX  changed=YYY  unreachable=0    failed=0    skipped=ZZZ
```

### 6. Trust SSL Certificate

Visit `https://yourproject.test` in your browser. You'll see a security warning (expected for self-signed certificates).

**Safari:**
1. Click "Show Details" → "visit this website"
2. Enter macOS password to trust certificate

**Chrome:**
1. Click "Advanced" → "Proceed to yourproject.test (unsafe)"
2. Or type `thisisunsafe` anywhere on the warning page

## Database and Files Setup

Choose one of these options:

### Option 1: Fresh WordPress Installation

If you just provisioned for the first time, you already have a fresh WordPress installation.

**Access WordPress:**
- URL: `https://yourproject.test/wp/wp-admin/`
- Username: `admin` (or as configured in `wordpress_sites.yml`)
- Password: `admin` (or as configured)

**Configure site:**
1. Log in to WordPress admin
2. Activate your theme (Appearance → Themes)
3. Configure settings as needed

### Option 2: Pull from Production (Recommended)

Pull production database and uploads to get real content.

#### Pull Database

**Method 1: Ansible Playbook**

```bash
cd trellis

# Backup development database first (optional but recommended)
ansible-playbook database-backup.yml -e env=development -e site=yourproject.com

# Pull from production to development
ansible-playbook database-pull.yml -e env=production -e site=yourproject.com
```

**Note:** This requires the `database-pull.yml` playbook in your Trellis directory. If not present, copy from [trellis-tools/backup/trellis/](../../backup/trellis/).

**Method 2: Direct VM Commands**

If Ansible playbooks fail (e.g., port 3306 conflicts):

```bash
trellis vm shell --workdir /srv/www/yourproject.com/current -- bash -c "
echo '=== Backing up current development database ==='
wp db export /tmp/dev_backup_\$(date +%Y%m%d_%H%M%S).sql.gz --path=web/wp

echo ''
echo '=== Pulling production database dump ==='
ssh -o StrictHostKeyChecking=no web@yourproject.com 'cd /srv/www/yourproject.com/current && wp db export - --path=web/wp' | gzip > /tmp/prod_import.sql.gz

echo ''
echo '=== Importing production database to development ==='
gunzip < /tmp/prod_import.sql.gz | wp db import - --path=web/wp

echo ''
echo '=== Running search-replace for URLs ==='
wp search-replace 'https://yourproject.com' 'https://yourproject.test' --all-tables --precise --path=web/wp

echo ''
echo '=== Flushing cache ==='
wp cache flush --path=web/wp

echo ''
echo '=== Database pull complete! ==='
"
```

**Requirements:**
- SSH key added to production server
- Production access configured

#### Pull Uploads

```bash
cd trellis

# Pull uploads from production to development
ansible-playbook files-pull.yml -e env=production -e site=yourproject.com
```

**What this does:**
- Syncs `/srv/www/yourproject.com/shared/uploads/` from production
- Uses rsync (incremental transfers)
- Time varies based on upload size (~5-10 minutes typical)

## Theme Development

### Start Development Server

```bash
cd site/web/app/themes/your-theme

# Using pnpm
pnpm dev

# OR using npm
npm run dev
```

**What this does:**
- Starts Vite dev server with HMR (Hot Module Replacement)
- Watches for file changes in `resources/`
- Auto-reloads browser on changes
- Proxies requests to your local site

**Expected output:**
```
VITE v5.x.x  ready in XXX ms

➜  Local:   http://localhost:3000/
➜  Network: use --host to expose
```

**Access:**
- **With HMR:** `http://localhost:3000` (recommended for development)
- **Direct:** `https://yourproject.test`

### Build for Production

Before deploying to staging/production:

```bash
cd site/web/app/themes/your-theme

# Using pnpm
pnpm build

# OR using npm
npm run build
```

**What this does:**
- Compiles and minifies CSS/JS
- Generates `public/build/` directory with versioned assets
- Optimizes for production

## Production Access

**Note:** Only needed when deploying or accessing production server.

### Add SSH Key to Production

When setting up a new machine, you need to add your SSH key to the production server.

#### Prerequisites

1. **Add your SSH key to GitHub:**
   ```bash
   # Display your public key
   cat ~/.ssh/id_ed25519.pub

   # Add it to GitHub: https://github.com/settings/keys
   ```

2. **Verify your key is in the Trellis users configuration:**

   Check `trellis/group_vars/all/users.yml` includes your GitHub username:
   ```yaml
   users:
     - name: "{{ web_user }}"
       keys:
         - https://github.com/YOUR_USERNAME.keys
   ```

#### Provision SSH Keys to Production

**IMPORTANT:** This step requires someone with existing production access.

From a machine that already has SSH access to production:

```bash
cd /path/to/yourproject/trellis

# Provision users (updates authorized_keys from GitHub)
trellis provision --tags users production
```

**What this does:**
- Fetches SSH keys from GitHub URLs configured in `users.yml`
- Updates `/home/web/.ssh/authorized_keys` (for web user)
- Updates `/home/warden/.ssh/authorized_keys` (for admin user)
- **Does NOT update** `/root/.ssh/authorized_keys` (root SSH disabled for security)

**Expected output:**
```
PLAY RECAP ***************************************************************
yourproject.com : ok=XX  changed=X  unreachable=0  failed=0
```

**Time:** ~30 seconds to 2 minutes

#### Verify Production Access

From your new machine:

```bash
# Test SSH connection as web user
ssh web@yourproject.com

# Should get shell access
# If successful: web@yourproject:~$

# Test SSH connection as admin user
ssh warden@yourproject.com

# Should get shell access
# If successful: warden@yourproject:~$
```

**Note:** Root SSH access is disabled for security. Use `warden` (admin user) for sudo access.

#### Troubleshooting

**Problem:** `Permission denied (publickey)` after provisioning

**Solutions:**
1. Verify your key is on GitHub: `curl https://github.com/YOUR_USERNAME.keys`
2. Wait 1-2 minutes for GitHub to update its cache
3. Re-run provisioning: `trellis provision --tags users production`
4. Check if key was added: `ssh warden@yourproject.com "cat /home/web/.ssh/authorized_keys"`

### Deploy to Production

```bash
cd trellis
trellis deploy production
```

**What this does:**
- Pulls latest code from configured branch (usually `main`)
- Runs `composer install --no-dev --optimize-autoloader`
- Runs theme build process
- Activates new release
- Keeps previous releases for rollback

## Common Workflows

### Daily Development

```bash
# Start VM (if not running)
cd trellis && trellis vm start

# Start theme dev server (in another terminal)
cd site/web/app/themes/your-theme && pnpm dev

# Visit http://localhost:3000 for HMR
```

### Stop VM (Save Resources)

```bash
cd trellis
trellis vm stop
```

### Delete VM (Fresh Start)

```bash
cd trellis
trellis vm delete

# Then re-provision
trellis vm start
trellis provision development
```

### Run WP-CLI Commands

```bash
# From host machine
trellis vm shell -- wp cache flush --path=/srv/www/yourproject.com/current/web/wp
trellis vm shell -- wp plugin list --path=/srv/www/yourproject.com/current/web/wp

# OR enter VM interactively
trellis vm shell --workdir /srv/www/yourproject.com/current
# Now run: wp cache flush --path=web/wp
```

## Troubleshooting

### File Changes Not Appearing

**Symptom:** Code changes don't appear in browser

**Cause:** Usually WordPress cache, not file sync

**Solution:**
```bash
# Flush WordPress cache
trellis vm shell -- wp cache flush --path=/srv/www/yourproject.com/current/web/wp

# Hard refresh browser (Cmd+Shift+R)

# For CSS/JS changes, restart Vite
cd site/web/app/themes/your-theme && pnpm dev
```

### Port 3306 Conflict

**Symptom:** Ansible playbooks fail with SSH errors

**Cause:** Local MariaDB/MySQL conflicts with Trellis VM

**Solution:** Run WP-CLI commands inside VM:
```bash
trellis vm shell --workdir /srv/www/yourproject.com/current
wp db export /tmp/backup.sql.gz --path=web/wp
```

### SSL Certificate Warning

**Symptom:** Browser shows "Your connection is not private"

**Cause:** Self-signed certificate for local development

**Solution:**
- Click "Advanced" → "Proceed" (safe for local dev)
- Or type `thisisunsafe` on warning page (Chrome)

### VM Won't Start

**Symptom:** `trellis vm start` fails or hangs

**Solution:**
```bash
# Check Lima VM status
limactl list

# Delete and recreate VM
trellis vm delete
trellis vm start
trellis provision development
```

### Composer Memory Errors

**Symptom:** `composer install` fails with memory error

**Solution:**
```bash
php -d memory_limit=-1 $(which composer) install
```

## Verification Checklist

After setup, verify everything works:

- [ ] Trellis VM running: `trellis vm status`
- [ ] Site accessible: Visit `https://yourproject.test`
- [ ] WordPress admin accessible: `https://yourproject.test/wp/wp-admin/`
- [ ] Theme dev server works: Run dev server and visit `http://localhost:3000`
- [ ] HMR works: Edit CSS file and see instant changes
- [ ] WP-CLI works: `trellis vm shell -- wp cli info --path=/srv/www/yourproject.com/current/web/wp`
- [ ] Database accessible: `trellis vm shell -- wp db check --path=/srv/www/yourproject.com/current/web/wp`
- [ ] Composer packages installed: `ls -la site/vendor/`
- [ ] Theme packages installed: `ls -la site/web/app/themes/your-theme/node_modules/`

## Next Steps

1. **Familiarize with codebase:**
   - Review theme documentation
   - Understand project structure
   - Check for project-specific CLAUDE.md or README.md

2. **Configure IDE:**
   - Install PHP CodeSniffer extension
   - Configure ESLint and Prettier
   - Set up framework-specific syntax highlighting

3. **Review project workflows:**
   - Check deployment process
   - Understand branching strategy
   - Review code standards

## Resources

- **Trellis Docs:** https://roots.io/trellis/docs/
- **Bedrock Docs:** https://roots.io/bedrock/docs/
- **Sage Docs:** https://roots.io/sage/docs/
- **Trellis VM Docs:** https://roots.io/trellis/docs/trellis-vm/
- **Trellis Tools (backup/migration):** [../../README.md](../../README.md)

## Quick Reference

```bash
# Initial Setup
trellis init                          # Initialize Trellis (run once)

# VM Management
trellis vm start                      # Start VM
trellis vm stop                       # Stop VM
trellis vm shell                      # SSH into VM
trellis vm delete                     # Delete VM

# Provisioning
trellis provision development         # Provision development
trellis provision production          # Provision production

# Deployment
trellis deploy staging                # Deploy to staging
trellis deploy production             # Deploy to production

# Database Operations (requires playbooks in trellis/)
ansible-playbook database-backup.yml -e env=production -e site=yourproject.com
ansible-playbook database-pull.yml -e env=production -e site=yourproject.com
ansible-playbook files-pull.yml -e env=production -e site=yourproject.com

# Theme Development
pnpm dev          # Start dev server with HMR
pnpm build        # Build for production

# WP-CLI
trellis vm shell -- wp cache flush --path=/srv/www/yourproject.com/current/web/wp
trellis vm shell -- wp plugin list --path=/srv/www/yourproject.com/current/web/wp
```

## Project-Specific Notes

**This is a template guide.** Your specific project may have:
- Additional dependencies or plugins requiring authentication
- Custom deployment workflows
- Specific multisite configuration
- Project-specific scripts or tools

Check your project's `README.md` or `CLAUDE.md` for additional setup instructions.
