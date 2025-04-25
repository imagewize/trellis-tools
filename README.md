# Trellis Tools

A collection of tools to enhance your [Roots Trellis](https://roots.io/trellis/) workflow and configuration.

## Tools Overview

### 1. Trellis Updater

A Bash script to safely update your Trellis installation while preserving your custom configurations.

#### Features

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

#### Usage

1. Edit the script to set your project slug:
```bash
# Set your project slug here like imagewize.com
PROJECT="your-site-name"
```

2. Make the script executable:
```bash
chmod +x trellis-updater.sh
```

3. Run the script:
```bash
./trellis-updater.sh
```

4. Review the changes in your Git repository before pushing them.

### 2. Nginx Image Configuration

Tools to configure Nginx for optimized image serving, supporting WebP and AVIF formats.

#### Features

- Automatically serves WebP or AVIF images when browsers support them
- Falls back to traditional formats for older browsers
- Improves page load times and performance scores

#### Usage

The configuration is located in the `nginx.-includes/webp-avf.conf.j2` file. 

For detailed instructions on implementing this in your Trellis project and converting your images to WebP/AVIF formats, please refer to our [Image Optimization Guide](image-optimization.md).

To implement this in your Trellis project:
1. Copy the `nginx.-includes` directory to your Trellis project
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

## What Trellis Updater Preserves

The updater script specifically preserves the following files/directories:
- `.vault_pass`
- `.trellis/`
- `.git/`
- `.github/`
- `group_vars/all/vault.yml`
- `group_vars/development/vault.yml`
- `group_vars/development/wordpress_sites.yml`
- `group_vars/production/vault.yml`
- `group_vars/production/wordpress_sites.yml`
- `group_vars/staging/vault.yml`
- `group_vars/staging/wordpress_sites.yml`
- `group_vars/all/users.yml`
- `trellis.cli.yml`
- `hosts/` directory

## Requirements

- Git
- Bash
- rsync

## License

MIT License. See [LICENSE.md](LICENSE.md) for details.

## Author

Copyright © Imagewize