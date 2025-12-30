# New Machine Setup Guide

Complete setup guide for setting up a Trellis-based WordPress development environment on a new machine.

**Target Project:** imagewize.com (Roots.io stack: Trellis + Bedrock + Sage 11)

## Prerequisites

### Understanding the Two Environments

**Important distinction:**

- **Host Machine (macOS):** Your local Mac where you edit code and run development tools
- **Trellis VM (Lima/Ubuntu):** Virtual machine that runs the WordPress LEMP stack

**What runs where:**

| Tool | Host Machine | Trellis VM | Purpose |
|------|-------------|------------|---------|
| Trellis CLI | ✅ Required | ❌ | Manages the VM |
| Composer | ✅ Required | ✅ Included | Installs PHP dependencies locally |
| PHP | ✅ Required | ✅ Included | Runs Composer on host; runs WordPress in VM |
| Node.js/npm | ✅ Required | ❌ | Runs Vite dev server on host |
| pnpm | ✅ Optional | ❌ | Faster npm alternative for host |
| MySQL/MariaDB | ❌ Conflicts! | ✅ Included | WordPress database in VM only |
| Nginx | ❌ Conflicts! | ✅ Included | Web server in VM only |
| PHP-FPM | ❌ Conflicts! | ✅ Included | WordPress PHP runtime in VM only |
| WP-CLI | ❌ Optional | ✅ Included | WordPress CLI (run via `trellis vm shell`) |

**Key points:**
- **Host tools** are for development workflow (building assets, installing dependencies)
- **VM tools** are for running WordPress (web server, database, PHP runtime)
- Files are synced bidirectionally between host and VM via Lima
- You edit code on your host Mac, but WordPress runs inside the VM

**Compatibility note:**
- If you use Laravel Valet, you already have PHP/Composer/MySQL on your host
- This is fine! Trellis VM uses its own isolated environment
- Just be aware that local MySQL on port 3306 may conflict with some Ansible commands
- Solution: Run WP-CLI commands inside the VM via `trellis vm shell`

### Required Tools (Host Machine)

Install these tools on your Mac via Homebrew:

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Trellis CLI (required - manages the VM)
brew install roots/tap/trellis-cli

# Install Composer (required - installs PHP dependencies)
brew install composer

# Install PHP (required - runs Composer)
brew install php

# Install Node.js (required - runs Vite dev server for theme assets)
# Option 1: Via fnm (Fast Node Manager, recommended)
brew install fnm
fnm install 24  # Install Node.js 24 LTS
fnm use 24

# Option 2: Direct installation via Homebrew
# brew install node

# Install pnpm (optional but recommended - faster npm alternative)
npm install -g pnpm
```

**Note for Laravel Valet users:**
- You likely already have PHP, Composer, and MySQL installed
- No need to reinstall - your existing versions work fine
- Trellis VM runs its own isolated LEMP stack
- Only potential conflict: Local MySQL on port 3306 (see Troubleshooting section)

### Verify Installation

Check that all tools are installed correctly:

```bash
trellis --version    # Should show 1.17.0+
composer --version   # Should show 2.9.0+
php --version        # Should show 8.3.0+
node --version       # Should show v24.0.0+
npm --version        # Should show 11.0.0+
pnpm --version       # Should show 10.0.0+ (if installed)
```

### SSH Key Setup

If you don't already have an SSH key:

```bash
# Generate new SSH key (use your email)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub | pbcopy
```

**Add to GitHub:**
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Paste your public key
4. Test: `ssh -T git@github.com`

**Add to Production Server (for deployments):**
- This step can be done later when you need production access
- See "Production SSH Access" section below

## How It All Works Together

### Development Workflow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ HOST MACHINE (macOS)                                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Your Code Editor (VS Code, PHPStorm, etc.)                │
│  ↓                                                          │
│  ~/code/imagewize.com/                                      │
│  ├── site/                                                  │
│  │   ├── composer.json     ← Composer installs here       │
│  │   └── web/app/themes/nynaeve/                           │
│  │       ├── package.json  ← npm/pnpm installs here       │
│  │       ├── resources/    ← You edit CSS/JS here         │
│  │       └── public/       ← Vite builds assets here      │
│  └── trellis/              ← Trellis CLI runs here         │
│                                                             │
│  Terminal Commands:                                         │
│  • npm run dev          (Vite dev server, HMR)             │
│  • composer install     (Install PHP dependencies)         │
│  • trellis vm start     (Start VM)                         │
│  • trellis provision    (Provision VM)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           ↕ ↕ ↕
            Lima syncs files bidirectionally
                           ↕ ↕ ↕
┌─────────────────────────────────────────────────────────────┐
│ TRELLIS VM (Lima/Ubuntu)                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  /srv/www/imagewize.com/current/    ← Synced from host    │
│                                                             │
│  LEMP Stack (runs WordPress):                               │
│  • Nginx (port 80/443)      → Web server                   │
│  • PHP-FPM 8.3              → Executes WordPress PHP       │
│  • MySQL 8.0                → WordPress database           │
│  • WP-CLI                   → WordPress management         │
│                                                             │
│  Access via:                                                │
│  • trellis vm shell         (Interactive shell)            │
│  • https://imagewize.test   (Web browser)                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Two Environments?

**Host Machine handles:**
- **Code editing:** You edit files on your Mac with your preferred editor
- **Asset building:** Vite compiles CSS/JS with HMR for instant feedback
- **Dependency management:** Composer and npm download packages locally
- **Version control:** Git operations happen on your Mac

**Trellis VM handles:**
- **WordPress runtime:** Nginx serves PHP files through PHP-FPM
- **Database:** MySQL stores WordPress content
- **WordPress core:** All WordPress PHP execution happens here
- **Production parity:** VM matches production server configuration

**Benefits:**
- **Isolated environment:** VM can't conflict with your Laravel Valet setup
- **Production parity:** VM matches production Ubuntu/Nginx/PHP versions
- **Fast development:** Edit files on Mac, see changes instantly via file sync
- **No containers:** Lima is lighter than Docker, faster than Vagrant

### Common Confusion: Do I Need Duplicate Tools?

**No!** Here's why you need each tool on the host:

- **Composer on host:** Downloads dependencies to `vendor/` which syncs to VM
  - VM also has Composer, but you run it on host for speed

- **Node.js on host:** Runs Vite dev server for HMR (hot reload)
  - VM doesn't need Node.js - it just serves the compiled assets

- **PHP on host:** Only needed to run Composer
  - WordPress doesn't run on host PHP - it runs in VM's PHP-FPM

- **No MySQL on host:** Would conflict with VM's MySQL on port 3306
  - If you have MySQL from Valet, stop it or run WP-CLI in VM

**Real-world example:**
```bash
# On HOST: Install dependencies and build assets
cd ~/code/imagewize.com/site/web/app/themes/nynaeve
pnpm install        # Host Node.js downloads packages
pnpm run dev        # Host Node.js runs Vite dev server

# Files auto-sync to VM via Lima
# WordPress in VM serves your site with the built assets

# On VM: Run WordPress commands
trellis vm shell    # Enter VM
wp cache flush      # VM's WP-CLI talks to VM's MySQL
```

## Repository Setup

### 1. Clone Repository

```bash
cd ~/code
git clone git@github.com:imagewize/imagewize.com.git
cd imagewize.com
```

### 2. Install Site Dependencies (Bedrock)

**Important:** Before running `composer install`, you need to configure authentication for Advanced Custom Fields Pro.

#### Set up ACF Pro Authentication

The site uses Advanced Custom Fields Pro, which requires a license key for Composer installation.

1. Create `site/auth.json` with your ACF Pro license key:

```bash
cd site
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

2. Replace `YOUR_ACF_LICENSE_KEY` with the actual license key
3. Replace `YOUR_SITE_URL` with your site URL (e.g., `imagewize.com`)

**Security note:** The `auth.json` file is already in `.gitignore` and should never be committed.

**Documentation:** [Installing ACF Pro with Composer](https://www.advancedcustomfields.com/resources/installing-acf-pro-with-composer/)

#### Install Dependencies

```bash
# Still in site directory
composer install
```

**What this installs:**
- WordPress core
- WordPress plugins (via Composer)
- Advanced Custom Fields Pro
- Bedrock boilerplate dependencies

**Output:** Creates `site/vendor/` directory with ~100MB of packages

### 3. Install Theme Dependencies (Sage 11)

```bash
cd web/app/themes/nynaeve

# Option 1: Using pnpm (faster, recommended)
pnpm install

# Option 2: Using npm
npm install
```

**What this installs:**
- Vite (build tool)
- Tailwind CSS 4
- Laravel Mix dependencies
- Sage 11 theme framework

**Output:** Creates `node_modules/` directory with ~400MB of packages

## Trellis VM Setup

### 1. Start Trellis VM

Trellis uses Lima (lightweight VM) instead of Vagrant for local development.

```bash
cd trellis
trellis vm start
```

**What this does:**
- Creates a Lima VM with Ubuntu 24.04
- Mounts project directory to `/srv/www/imagewize.com/current`
- Starts VM with 2 CPUs and 4GB RAM (configurable in `trellis.yml`)
- Sets up bidirectional file sync between host and VM

**First-time setup takes:** ~2-5 minutes

**Expected output:**
```
Starting VM...
VM started successfully.
VM IP: 192.168.56.5
```

### 2. Provision Development Environment

```bash
# Still in trellis directory
trellis provision development
```

**What this does:**
- Installs LEMP stack (Linux, Nginx, MySQL, PHP)
- Configures Nginx virtual hosts
- Sets up PHP-FPM
- Creates MySQL database
- Installs WordPress via WP-CLI
- Configures SSL certificates (self-signed for local)
- Sets up automatic file sync

**First-time provisioning takes:** ~10-15 minutes

**Expected output:**
```
PLAY RECAP ***************************************************************
192.168.56.5 : ok=XXX  changed=YYY  unreachable=0    failed=0    skipped=ZZZ
```

### 3. Verify /etc/hosts (Automatic)

**Good news:** Trellis CLI automatically adds site hosts to `/etc/hosts` when you run `trellis vm start`.

You can verify it was added correctly:

```bash
grep imagewize.test /etc/hosts
```

**Expected output:** `192.168.56.5  imagewize.test`

**If missing:** The automatic update requires sudo access. If it failed, add manually:
```bash
sudo sh -c 'echo "192.168.56.5  imagewize.test" >> /etc/hosts'
```

**Note:** When you first run `trellis vm start`, the CLI will:
- Generate a Lima config file (`.trellis/lima/imagewize.com.yml`)
- Create the Lima instance
- Generate an Ansible inventory for the VM
- **Automatically add your site hosts to `/etc/hosts`**

See: [Trellis VM Integration Details](https://roots.io/trellis/docs/local-development/#integration-details)

### 4. Trust SSL Certificate

The first time you visit `https://imagewize.test`, your browser will show a security warning because the SSL certificate is self-signed.

**Safari:**
1. Visit `https://imagewize.test`
2. Click "Show Details" → "visit this website"
3. Enter macOS password to trust certificate

**Chrome:**
1. Visit `https://imagewize.test`
2. Click "Advanced" → "Proceed to imagewize.test (unsafe)"
3. Or: Type `thisisunsafe` anywhere on the warning page

## Database and Files Setup

### Option 1: Fresh WordPress Installation

If you just provisioned for the first time, you already have a fresh WordPress installation.

**Access WordPress:**
- URL: `https://imagewize.test/wp/wp-admin/`
- Username: `admin`
- Password: `admin`

**Configure site:**
1. Log in to WordPress admin
2. Go to Settings → General
3. Update site title, tagline, etc.
4. Activate Nynaeve theme (Appearance → Themes)

### Option 2: Pull from Production (Recommended)

Pull the production database and uploads to get real content:

#### Pull Database

**Method 1: Ansible Playbook (if working)**

```bash
cd trellis

# Backup development database first (optional but recommended)
ansible-playbook database-backup.yml -e env=development -e site=imagewize.com

# Pull from production to development
ansible-playbook database-pull.yml -e env=production -e site=imagewize.com
```

**Method 2: Direct VM Commands (if Ansible fails due to local database conflicts)**

```bash
trellis vm shell --workdir /srv/www/imagewize.com/current -- bash -c "
echo '=== Backing up current development database ==='
wp db export /tmp/dev_backup_\$(date +%Y%m%d_%H%M%S).sql.gz --path=web/wp

echo ''
echo '=== Pulling production database dump ==='
ssh -o StrictHostKeyChecking=no web@imagewize.com 'cd /srv/www/imagewize.com/current && wp db export - --path=web/wp' | gzip > /tmp/prod_import.sql.gz

echo ''
echo '=== Importing production database to development ==='
gunzip < /tmp/prod_import.sql.gz | wp db import - --path=web/wp

echo ''
echo '=== Running search-replace for URLs ==='
wp search-replace 'https://imagewize.com' 'https://imagewize.test' --all-tables --precise --path=web/wp

echo ''
echo '=== Flushing cache ==='
wp cache flush --path=web/wp

echo ''
echo '=== Database pull complete! ==='
"
```

**Note:** Method 2 requires your SSH key to be added to production server. If you don't have production access yet, use Method 1 or stick with fresh installation.

#### Pull Uploads

```bash
cd trellis

# Pull uploads from production to development
ansible-playbook files-pull.yml -e env=production -e site=imagewize.com
```

**What this does:**
- Syncs `/srv/www/imagewize.com/shared/uploads/` from production to development
- Uses rsync (incremental, only transfers changed files)
- Takes ~5-10 minutes depending on upload size

### Option 3: Use Backup Scripts (Convenience Wrappers)

For quick database backups, use the helper scripts:

```bash
# From repository root
./scripts/backup-db.sh       # Backup main site
./scripts/backup-db.sh demo  # Backup demo site
```

**Output:** Creates timestamped `.sql.gz` file in `site/database_backup/`

## Theme Development

### Start Development Server

```bash
cd site/web/app/themes/nynaeve
npm run dev
# or: pnpm dev
```

**What this does:**
- Starts Vite dev server with HMR (Hot Module Replacement)
- Watches for file changes in `resources/css/` and `resources/js/`
- Auto-reloads browser on changes
- Proxies requests to `https://imagewize.test`

**Expected output:**
```
VITE v5.x.x  ready in XXX ms

➜  Local:   http://localhost:3000/
➜  Network: use --host to expose
➜  press h to show help
```

**Access site with HMR:** `http://localhost:3000` (proxies to `https://imagewize.test`)

### Build for Production

```bash
cd site/web/app/themes/nynaeve
npm run build
# or: pnpm build
```

**What this does:**
- Compiles and minifies CSS/JS
- Generates `public/build/` directory with versioned assets
- Creates `theme.json` from Tailwind config

**When to run:** Before deploying to staging/production

## Production SSH Access

**Note:** Only needed when you want to deploy to production or access production server directly.

### Add SSH Key to Production

Your SSH public key needs to be added to the production server's `authorized_keys`.

**Option 1: Ask existing admin to add your key**

Send your public key to an existing admin:

```bash
cat ~/.ssh/id_ed25519.pub
```

They will add it to `/home/web/.ssh/authorized_keys` on the production server.

**Option 2: Add via Trellis (if you have sudo access)**

1. Edit `trellis/group_vars/all/users.yml`
2. Add your public key to the `web_user` or `admin_user` keys list
3. Re-provision production:
   ```bash
   trellis provision --tags users production
   ```

### Verify Production Access

```bash
# Test SSH connection
ssh web@imagewize.com

# Should get shell access to production server
# If successful, you'll see:
# web@imagewize:~$
```

### Deploy to Production

Once you have SSH access:

```bash
cd trellis
trellis deploy production
```

**What this does:**
- Pulls latest code from `main` branch
- Runs `composer install --no-dev --optimize-autoloader`
- Runs `npm run build` in theme directory
- Activates new release
- Keeps 5 previous releases for rollback

## Common Workflows

### Daily Development

```bash
# Start VM (if not running)
cd trellis && trellis vm start

# Start theme dev server
cd site/web/app/themes/nynaeve && npm run dev

# Visit http://localhost:3000 for HMR
# Visit https://imagewize.test for direct access
```

### Create New Block

```bash
# Must run from Trellis VM (requires database access)
cd trellis
trellis vm shell --workdir /srv/www/imagewize.com/current/web/app/themes/nynaeve -- wp acorn sage-native-block:create

# Follow interactive prompts to select template
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
# Then run trellis vm start and trellis provision development again
```

## Troubleshooting

### Port 3306 Conflict (Local Database)

**Symptom:** Ansible playbooks fail with SSH connection errors to 192.168.56.5

**Cause:** Local MariaDB/MySQL running on port 3306 conflicts with Trellis VM

**Solution:** Run WP-CLI commands inside Trellis VM instead:

```bash
# Instead of Ansible playbooks, use direct VM commands
trellis vm shell --workdir /srv/www/imagewize.com/current

# Now run WP-CLI commands
wp db export /tmp/backup.sql.gz --path=web/wp
wp cache flush --path=web/wp
```

### File Changes Not Appearing

**Symptom:** Code changes in theme files don't appear in browser

**Cause:** Usually WordPress cache, not file sync (Lima handles sync automatically)

**Solution:**

```bash
# Flush WordPress cache
trellis vm shell --workdir /srv/www/imagewize.com/current -- wp cache flush --path=web/wp

# Hard refresh browser (Cmd+Shift+R)

# For CSS/JS changes, restart Vite dev server
cd site/web/app/themes/nynaeve
npm run dev
```

### SSL Certificate Warning

**Symptom:** Browser shows "Your connection is not private" warning

**Cause:** Self-signed SSL certificate for local development

**Solution:**
- Click "Advanced" → "Proceed to imagewize.test" (safe for local dev)
- Or: Type `thisisunsafe` on the warning page (Chrome)

### VM Won't Start

**Symptom:** `trellis vm start` fails or hangs

**Solution:**

```bash
# Check Lima VM status
limactl list

# Stop and delete VM
trellis vm delete

# Start fresh
trellis vm start
trellis provision development
```

### Composer Memory Errors

**Symptom:** `composer install` fails with "Allowed memory size exhausted"

**Solution:**

```bash
# Run Composer with unlimited memory
php -d memory_limit=-1 $(which composer) install
```

## Important Notes

### Local Database Conflicts

- If you have MariaDB/MySQL installed via Homebrew, it may conflict with Trellis VM
- Trellis VM runs MySQL on port 3306 inside the VM
- Lima handles port forwarding, but local databases can interfere
- **Best practice:** Run all WP-CLI commands inside Trellis VM via `trellis vm shell`

### Trellis VM vs Vagrant

- **Old setup:** Trellis used Vagrant (VirtualBox)
- **New setup:** Trellis uses Lima (lightweight VM)
- Access via: `trellis vm shell` (NOT `vagrant ssh`)
- File sync is automatic and bidirectional
- No need for `vagrant reload` or manual rsync

### WordPress Development Mode

For theme development, enable development mode in `config/environments/development.php`:

```php
Config::define('WP_DEVELOPMENT_MODE', 'theme');
```

This bypasses theme.json and block theme caching for faster iteration.

### Demo Site (Multisite)

The repository also includes a demo site at `demo/` which is a WordPress multisite installation using the Moiraine theme.

**To provision demo site:**

```bash
# Update /etc/hosts
sudo sh -c 'echo "192.168.56.5  demo.imagewize.test" >> /etc/hosts'

# Access at: https://demo.imagewize.test
```

**Important:** Demo site commits should NOT include Claude Code attribution.

## Verification Checklist

After setup, verify everything works:

- [ ] Trellis VM is running: `trellis vm status`
- [ ] Site accessible: Visit `https://imagewize.test`
- [ ] WordPress admin accessible: `https://imagewize.test/wp/wp-admin/`
- [ ] Theme dev server works: `npm run dev` and visit `http://localhost:3000`
- [ ] HMR works: Edit a CSS file and see changes instantly
- [ ] WP-CLI works: `trellis vm shell -- wp cli info --path=/srv/www/imagewize.com/current/web/wp`
- [ ] Database accessible: `trellis vm shell -- wp db check --path=/srv/www/imagewize.com/current/web/wp`
- [ ] Composer packages installed: `ls -la site/vendor/`
- [ ] Theme packages installed: `ls -la site/web/app/themes/nynaeve/node_modules/`

## Next Steps

1. **Familiarize with codebase:**
   - Read `site/web/app/themes/nynaeve/README.md`
   - Review custom blocks in `resources/js/blocks/`
   - Understand Tailwind config in `tailwind.config.js`

2. **Set up IDE:**
   - Install PHP CodeSniffer extension
   - Configure ESLint and Prettier
   - Set up Blade syntax highlighting

3. **Run tests:**
   ```bash
   cd site
   composer test  # Runs PHP CodeSniffer
   ```

4. **Request production access:**
   - Share your SSH public key with team lead
   - Wait for confirmation before attempting deployments

## Resources

- **Trellis Docs:** https://roots.io/trellis/docs/
- **Bedrock Docs:** https://roots.io/bedrock/docs/
- **Sage 11 Docs:** https://roots.io/sage/docs/
- **Project CLAUDE.md:** `/Users/j/code/imagewize.com/CLAUDE.md` (Claude Code instructions)
- **Trellis VM Docs:** https://roots.io/trellis/docs/trellis-vm/

## Quick Reference

```bash
# Start/stop VM
trellis vm start
trellis vm stop
trellis vm shell

# Provision
trellis provision development
trellis provision production

# Deploy
trellis deploy staging
trellis deploy production

# Database operations (from trellis/)
ansible-playbook database-backup.yml -e env=production -e site=imagewize.com
ansible-playbook database-pull.yml -e env=production -e site=imagewize.com
ansible-playbook files-pull.yml -e env=production -e site=imagewize.com

# Theme development (from theme directory)
npm run dev    # Start dev server with HMR
npm run build  # Build for production

# WP-CLI (from VM)
trellis vm shell -- wp cache flush --path=/srv/www/imagewize.com/current/web/wp
trellis vm shell -- wp plugin list --path=/srv/www/imagewize.com/current/web/wp
trellis vm shell -- wp theme list --path=/srv/www/imagewize.com/current/web/wp
```
