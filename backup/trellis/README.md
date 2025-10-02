# Trellis Backup Integration

Ansible playbooks for automated database backup, synchronization, and management across Trellis environments.

## Overview

This directory contains Ansible playbooks that integrate with your existing Trellis setup to provide automated database and files operations:

### Database Operations
- **database-backup.yml** - Create database backups from any environment
- **database-pull.yml** - Pull database from remote environment to development
- **database-push.yml** - Push database from development to remote environment

### Files Operations
- **files-backup.yml** - Create WordPress uploads backups from any environment
- **files-pull.yml** - Pull WordPress uploads from remote environment to development
- **files-push.yml** - Push WordPress uploads from development to remote environment

## Prerequisites

- Working Trellis installation with configured environments
- Ansible installed and configured
- SSH access to all target environments
- WP-CLI available on all servers (included with Trellis)

## Installation

1. Copy the playbook files to your Trellis directory:
   ```bash
   # From your trellis-tools directory
   cp -r backup/trellis/* /path/to/your/trellis/
   ```

2. Or reference them directly from this repository:
   ```bash
   # Run from your Trellis directory
   ansible-playbook /path/to/trellis-tools/backup/trellis/database-backup.yml -e site=example.com -e env=production
   ```

## Usage

All playbooks require two variables:
- `site` - The site name as defined in your Trellis configuration
- `env` - The environment (development, staging, production)

### Database Backup

Creates a compressed database backup and stores it in the `database_backup` directory.

```bash
# Backup production database
ansible-playbook database-backup.yml -e site=example.com -e env=production

# Backup staging database
ansible-playbook database-backup.yml -e site=example.com -e env=staging

# Backup development database
ansible-playbook database-backup.yml -e site=example.com -e env=development
```

**What it does:**
- Creates timestamped compressed SQL backup
- For remote environments: downloads backup to development server
- Stores backup in `web/app/database_backup/` directory
- Automatically cleans up temporary files

### Database Pull

Pulls database from a remote environment to development with automatic URL replacement.

```bash
# Pull production database to development
ansible-playbook database-pull.yml -e site=example.com -e env=production

# Pull staging database to development
ansible-playbook database-pull.yml -e site=example.com -e env=staging
```

**What it does:**
- Creates backup of current development database
- Exports database from remote environment
- Downloads and imports to development
- Performs URL search-replace for local development URLs
- Cleans up temporary files

**Note:** Cannot pull from development to development (will abort with error).

### Database Push

Pushes database from development to a remote environment with URL replacement.

```bash
# Push development database to staging
ansible-playbook database-push.yml -e site=example.com -e env=staging

# Push development database to production (use with caution!)
ansible-playbook database-push.yml -e site=example.com -e env=production
```

**What it does:**
- Creates backup of target environment database
- Exports development database
- Uploads and imports to target environment
- Performs URL search-replace for target environment URLs
- Cleans up temporary files

**Note:** Cannot push from development to development (will abort with error).

### Files Backup

Creates a compressed backup of WordPress uploads directory and stores it in the `files_backup` directory.

```bash
# Backup production uploads
ansible-playbook files-backup.yml -e site=example.com -e env=production

# Backup staging uploads
ansible-playbook files-backup.yml -e site=example.com -e env=staging

# Backup development uploads
ansible-playbook files-backup.yml -e site=example.com -e env=development
```

**What it does:**
- Creates timestamped compressed uploads backup
- For remote environments: downloads backup to development server
- Stores backup in `web/app/files_backup/` directory
- Automatically cleans up temporary files

### Files Pull

Pulls WordPress uploads from a remote environment to development.

```bash
# Pull production uploads to development
ansible-playbook files-pull.yml -e site=example.com -e env=production

# Pull staging uploads to development
ansible-playbook files-pull.yml -e site=example.com -e env=staging
```

**What it does:**
- Creates backup of current development uploads
- Creates archive of uploads from remote environment
- Downloads and extracts to development
- Cleans up temporary files

**Note:** Cannot pull from development to development (will abort with error).

### Files Push

Pushes WordPress uploads from development to a remote environment.

```bash
# Push development uploads to staging
ansible-playbook files-push.yml -e site=example.com -e env=staging

# Push development uploads to production (use with caution!)
ansible-playbook files-push.yml -e site=example.com -e env=production
```

**What it does:**
- Creates backup of target environment uploads
- Creates archive of development uploads
- Uploads and extracts to target environment
- Cleans up temporary files

**Note:** Cannot push from development to development (will abort with error).

## Configuration

### Site Configuration

Ensure your site is properly configured in your Trellis `group_vars` files:

```yaml
# group_vars/development/wordpress_sites.yml
wordpress_sites:
  example.com:
    site_hosts:
      - canonical: example.test
    local_path: ../site # Path to your Bedrock installation
    # ... other configuration
```

```yaml
# group_vars/production/wordpress_sites.yml
wordpress_sites:
  example.com:
    site_hosts:
      - canonical: example.com
    # ... other configuration
```

### Backup Directory Structure

Backups are stored in the following structure:
```
site/current/web/app/
├── database_backup/
│   ├── example_com_production_2023_12_01_14_30_45.sql.gz
│   ├── example_com_staging_2023_12_01_15_15_22.sql.gz
│   └── example_com_development_2023_12_01_16_45_33.sql.gz
└── files_backup/
    ├── example_com_production_uploads_2023_12_01_14_30_45.tar.gz
    ├── example_com_staging_uploads_2023_12_01_15_15_22.tar.gz
    └── example_com_development_uploads_2023_12_01_16_45_33.tar.gz
```

## File Naming Convention

Backup files use the following naming patterns:

### Database Backups
```
{site_name}_{environment}_{date}_{time}.sql.gz
```

### Files Backups
```
{site_name}_{environment}_uploads_{date}_{time}.tar.gz
```

Where:
- `site_name` - Site name with dots replaced by underscores
- `environment` - development, staging, or production
- `date` - YYYY_MM_DD format
- `time` - HH_MM_SS format

Examples:
- `example_com_production_2023_12_01_14_30_45.sql.gz`
- `example_com_production_uploads_2023_12_01_14_30_45.tar.gz`
- `mysite_co_uk_staging_2023_12_01_15_15_22.sql.gz`
- `mysite_co_uk_staging_uploads_2023_12_01_15_15_22.tar.gz`

## Compression Methods

Different compression methods are used based on backup type for optimal performance:

- **Database backups: `.sql.gz`** - Uses `gzip` compression for single SQL files. Faster with direct piping (`wp db export - | gzip`) without temporary files.
- **Files backups: `.tar.gz`** - Uses `tar` + `gzip` for directory archives. Required for preserving directory structure and handling multiple files efficiently.

## URL Search and Replace

The playbooks automatically handle URL replacement when moving databases between environments:

### Pull Operations
- **From Production**: `https://example.com` → `http://example.test`
- **From Staging**: `https://staging.example.com` → `http://example.test`

### Push Operations
- **To Production**: `http://example.test` → `https://example.com`
- **To Staging**: `http://example.test` → `https://staging.example.com`

URLs are determined from your Trellis site configuration using the `canonical` hostname.

## Security Considerations

1. **Backup Storage**: Backups contain sensitive data. Ensure proper file permissions on backup directories.

2. **Production Pushes**: Be extremely cautious when pushing to production. Always test on staging first.

3. **Database Credentials**: All database operations use WP-CLI, which reads credentials from WordPress configuration.

4. **SSH Access**: Ensure SSH keys are properly configured for all target environments.

## Error Handling

### Common Errors and Solutions

**"Site folder doesn't exist"**
- Verify the site name matches your Trellis configuration
- Check that the site has been deployed to the target environment

**"Cannot pull/push from development to development"**
- These operations are blocked by design
- Use `database-backup.yml` for development backups

**"WP-CLI command failed"**
- Verify WordPress is properly installed
- Check database connectivity
- Ensure WP-CLI is available on the server

**Permission denied errors**
- Verify SSH access to target servers
- Check file permissions in WordPress directories

## Automation

### Scheduled Backups

Add to your server's crontab for automated backups:

```bash
# Daily production backup at 2 AM
0 2 * * * cd /path/to/trellis && ansible-playbook database-backup.yml -e site=example.com -e env=production

# Weekly staging backup on Sundays at 3 AM
0 3 * * 0 cd /path/to/trellis && ansible-playbook database-backup.yml -e site=example.com -e env=staging
```

### Cleanup Script

Create a cleanup script to manage old backups:

```bash
#!/bin/bash
# cleanup-backups.sh

SITE_PATH="/srv/www/example.com/current/web/app"
RETENTION_DAYS=30

# Clean up old database backups
find "$SITE_PATH/database_backup" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Clean up old files backups
find "$SITE_PATH/files_backup" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Database Sync
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Source environment'
        required: true
        default: 'production'
        type: choice
        options:
        - production
        - staging

jobs:
  sync-database:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.7.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Pull database
        run: |
          cd trellis
          ansible-playbook database-pull.yml -e site=example.com -e env=${{ github.event.inputs.environment }}
```

## Troubleshooting

### Debug Mode

Run playbooks with verbose output for debugging:

```bash
ansible-playbook database-backup.yml -e site=example.com -e env=production -vvv
```

### Manual Verification

Verify backup integrity:

```bash
# Test database backup file
gunzip -t /path/to/backup.sql.gz

# Check database backup contents
gunzip -c /path/to/backup.sql.gz | head -20

# Test files backup file
tar -tzf /path/to/uploads.tar.gz

# Check files backup contents
tar -xzOf /path/to/uploads.tar.gz | head -20
```

### Log Monitoring

Monitor backup operations:

```bash
# Check Ansible logs
tail -f /var/log/ansible.log

# Check WordPress logs
tail -f /srv/www/example.com/shared/logs/error.log
```

## Best Practices

1. **Test First**: Always test pull/push operations on staging before production
2. **Backup Before Push**: The playbooks automatically create backups, but verify they complete successfully
3. **Monitor Disk Space**: Regular backups can consume significant disk space
4. **Document Procedures**: Keep a record of when and why database operations are performed
5. **Verify URLs**: Check that URL replacements work correctly after pull/push operations
6. **Regular Cleanup**: Implement automated cleanup of old backup files

## Support

For issues specific to these playbooks:
1. Check the Ansible output for specific error messages
2. Verify your Trellis configuration is correct
3. Test SSH connectivity to target servers
4. Ensure WP-CLI is working on all environments

For general Trellis support, refer to the [official Trellis documentation](https://roots.io/trellis/docs/).