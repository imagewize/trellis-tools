# Trellis Updater

A Bash script to safely update your [Roots Trellis](https://roots.io/trellis/) installation while preserving your custom configurations.

## Features

- Creates a backup of your current Trellis directory
- Downloads the latest version of Trellis
- Generates a diff to see what would change
- Updates your Trellis files while preserving important configurations:
  - Vault files with passwords and sensitive data
  - WordPress site configurations
  - User configurations
  - Host configurations
  - Trellis CLI configuration
- Commits changes to your Git repository

## What This Script Preserves

The updater script specifically preserves the following files/directories:

### Secrets & Credentials
- `.vault_pass`
- `group_vars/all/vault.yml`
- `group_vars/development/vault.yml`
- `group_vars/production/vault.yml`
- `group_vars/staging/vault.yml`

### Git & CI/CD
- `.git/`
- `.github/`
- `.trellis/`

### Site-Specific Configurations
- `group_vars/development/wordpress_sites.yml`
- `group_vars/production/wordpress_sites.yml`
- `group_vars/staging/wordpress_sites.yml`
- `group_vars/all/users.yml`
- `hosts/` directory
- `trellis.cli.yml`

### Custom PHP/Server Settings
- `group_vars/all/main.yml` - PHP memory limits, timezone, etc.
- `group_vars/production/main.yml` - PHP-FPM pool settings, MariaDB config
- `group_vars/staging/main.yml` - Environment-specific overrides
- `group_vars/development/main.yml` - Development settings

### Custom Deploy Hooks
- `deploy-hooks/` - Custom deployment scripts (e.g., memory limits for wp acorn)

## Post-Upgrade Manual Review

After upgrading, you should manually review and potentially merge changes from the new Trellis version:

1. **Role template changes** - Check if upstream changed any templates you've customized:
   - `roles/mariadb/templates/` - If you added custom MariaDB settings
   - `roles/wordpress-setup/templates/` - If you modified PHP-FPM pool templates

2. **New variables** - Check upstream `main.yml` files for new useful variables you may want to adopt

3. **Galaxy roles** - Run `ansible-galaxy install -r galaxy.yml` to update dependencies

## Usage

1. Edit the script to set your project slug:
```bash
# Set your project slug here like imagewize.com
PROJECT="your-site-name"
```

2. Make the script executable:
```bash
chmod +x updates/trellis-updater.sh
```

3. Run the script:
```bash
./updates/trellis-updater.sh
```

4. Review the changes in your Git repository before pushing them.

## Requirements

- Git
- Bash
- rsync

## License

MIT License. See [LICENSE.md](../LICENSE.md) for details.