# Trellis Site Backup Guide

A comprehensive guide for backing up WordPress sites running on Roots Trellis servers using shell scripts and WP-CLI.

## Overview

This guide covers multiple backup methods for Trellis-managed WordPress sites:

1. **Database Backups** - Using WP-CLI and mysqldump
2. **File System Backups** - Using rsync and tar
3. **Complete Site Backups** - Combining database and files
4. **Automated Backup Scripts** - Scheduled backups with retention

## Prerequisites

- SSH access to your Trellis server
- WP-CLI installed (included with Trellis)
- Sufficient storage space for backups
- Basic knowledge of shell commands

## Trellis Directory Structure

In Trellis, the recommended approach is to store backups in the `shared` directory which persists across deployments:

```
/srv/www/example.com/
├── current/           # Current WordPress installation (changes with deployments)
├── releases/          # Previous releases
└── shared/           # Persistent data (uploads, logs, configs)
    ├── uploads/
    ├── logs/
    └── database_backup/  # Create this for database backups
```

When running commands from `/srv/www/example.com/current`, create a `database_backup/` directory within the current WordPress installation (this matches the Trellis playbook approach).

## Method 1: WP-CLI Database Backup

### Basic Database Export

```bash
# SSH into your server
ssh web@your-server.com

# Navigate to your site directory
cd /srv/www/example.com/current

# Create backup directory in current WordPress directory (matches Trellis playbooks)
mkdir -p database_backup

# Export database (uncompressed)
wp db export database_backup/database-$(date +%Y%m%d_%H%M%S).sql --add-drop-table

# Export with compression (Mac-friendly .tar.gz extension)
BACKUP_FILE="database_backup/database-$(date +%Y%m%d_%H%M%S)"
wp db export ${BACKUP_FILE}.sql --add-drop-table
gzip ${BACKUP_FILE}.sql
mv ${BACKUP_FILE}.sql.gz ${BACKUP_FILE}.tar.gz
```

### Database Backup with Search & Replace

```bash
# Export database and replace URLs for local development (with Mac-friendly compression)
BACKUP_FILE="database_backup/database-$(date +%Y%m%d_%H%M%S)"
wp db export ${BACKUP_FILE}.sql \
  --add-drop-table \
  --search-replace=https://example.com,http://example.test
gzip ${BACKUP_FILE}.sql
mv ${BACKUP_FILE}.sql.gz ${BACKUP_FILE}.tar.gz
```

## Method 2: Shell Script Database Backup

### Using mysqldump

```bash
#!/bin/bash

# Database credentials (from your Trellis vault)
DB_NAME="example_production"
DB_USER="example"
DB_PASSWORD="your_password"
DB_HOST="localhost"

# Backup directory
BACKUP_DIR="/srv/www/example.com/shared/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create database backup
mysqldump \
  --host=$DB_HOST \
  --user=$DB_USER \
  --password=$DB_PASSWORD \
  --single-transaction \
  --routines \
  --triggers \
  $DB_NAME | gzip > $BACKUP_DIR/database_$DATE.sql.gz

echo "Database backup completed: $BACKUP_DIR/database_$DATE.sql.gz"
```

## Method 3: File System Backup

### Using rsync

```bash
#!/bin/bash

SITE_PATH="/srv/www/example.com"
BACKUP_DIR="/srv/backups/example.com"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup uploads directory
rsync -av --exclude=cache/ \
  $SITE_PATH/shared/uploads/ \
  $BACKUP_DIR/uploads_$DATE/

# Backup entire site (excluding cache and logs)
rsync -av \
  --exclude=shared/cache/ \
  --exclude=shared/logs/ \
  --exclude=.git/ \
  $SITE_PATH/ \
  $BACKUP_DIR/site_$DATE/
```

### Using tar

```bash
#!/bin/bash

SITE_PATH="/srv/www/example.com"
BACKUP_DIR="/srv/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create compressed archive of uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz \
  -C $SITE_PATH/shared uploads \
  --exclude=uploads/cache

# Create compressed archive of entire site
tar -czf $BACKUP_DIR/site_$DATE.tar.gz \
  -C /srv/www example.com \
  --exclude=example.com/shared/cache \
  --exclude=example.com/shared/logs \
  --exclude=example.com/.git
```

## Method 4: Complete Backup Script

Create a comprehensive backup script that combines database and file backups:

```bash
#!/bin/bash

# Configuration
SITE_NAME="example.com"
SITE_PATH="/srv/www/$SITE_NAME"
BACKUP_ROOT="/srv/backups"
BACKUP_DIR="$BACKUP_ROOT/$SITE_NAME"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Database credentials
DB_NAME="example_production"
DB_USER="example"
DB_PASSWORD="your_password"

# Create backup directories
mkdir -p $BACKUP_DIR/{database,files}

echo "Starting backup for $SITE_NAME at $(date)"

# 1. Database backup using WP-CLI
echo "Backing up database..."
cd $SITE_PATH/current
wp db export $BACKUP_DIR/database/db_$DATE.sql --add-drop-table
gzip $BACKUP_DIR/database/db_$DATE.sql

# 2. File backup
echo "Backing up files..."
tar -czf $BACKUP_DIR/files/uploads_$DATE.tar.gz \
  -C $SITE_PATH/shared uploads \
  --exclude=uploads/cache

# 3. Configuration backup
echo "Backing up configurations..."
tar -czf $BACKUP_DIR/files/config_$DATE.tar.gz \
  -C $SITE_PATH current/.env \
  shared/.env

# 4. Clean up old backups
echo "Cleaning up old backups..."
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed at $(date)"
echo "Backup location: $BACKUP_DIR"
```

## Method 5: Remote Backup Script

For backing up to a remote server:

```bash
#!/bin/bash

# Configuration
LOCAL_BACKUP_DIR="/srv/backups/example.com"
REMOTE_SERVER="backup.example.com"
REMOTE_USER="backup"
REMOTE_PATH="/backups/example.com"
DATE=$(date +%Y%m%d)

# Create today's backup using previous script
./site-backup.sh

# Sync to remote server
echo "Syncing backups to remote server..."
rsync -av --delete \
  --exclude='*.tmp' \
  $LOCAL_BACKUP_DIR/ \
  $REMOTE_USER@$REMOTE_SERVER:$REMOTE_PATH/

echo "Remote backup sync completed"
```

## Automation with Cron

Add to your server's crontab for automated backups:

```bash
# Edit crontab
sudo crontab -e

# Add these lines for daily backups at 2 AM
0 2 * * * /srv/scripts/site-backup.sh > /var/log/backup.log 2>&1

# Weekly cleanup at 3 AM on Sundays
0 3 * * 0 find /srv/backups -name "*.gz" -mtime +30 -delete
```

## Restoration Examples

### Database Restoration

```bash
# Using WP-CLI (uncompressed)
wp db import database_backup/database_20231201_020000.sql

# Using WP-CLI (compressed .tar.gz)
gunzip -c database_backup/database_20231201_020000.tar.gz | wp db import -

# Using mysql directly (compressed)
gunzip < database_backup/database_20231201_020000.tar.gz | mysql -u username -p database_name
```

### File Restoration

```bash
# Restore uploads
tar -xzf backups/uploads_20231201_020000.tar.gz -C /srv/www/example.com/shared/

# Restore specific files
rsync -av backups/site_20231201_020000/ /srv/www/example.com/
```

## Security Considerations

1. **Encrypt sensitive backups**: Use GPG for database backups containing sensitive data
2. **Secure backup storage**: Ensure backup directories have proper permissions (750 or 700)
3. **Database credentials**: Store credentials in a secure location, consider using environment variables
4. **Remote storage**: Use secure transfer methods (SSH/SFTP) for remote backups
5. **Access logs**: Monitor backup script execution and access to backup files

## Monitoring and Alerts

### Log Monitoring

```bash
# Check backup logs
tail -f /var/log/backup.log

# Check for backup failures
grep -i error /var/log/backup.log
```

### Disk Space Monitoring

```bash
# Check backup directory size
du -sh /srv/backups/*

# Check available disk space
df -h /srv/backups
```

## Troubleshooting

### Common Issues

1. **Permission denied**: Ensure proper file permissions and ownership
2. **Disk space**: Monitor available space before running backups
3. **Database connection**: Verify database credentials and connectivity
4. **WP-CLI errors**: Ensure you're in the correct WordPress directory

### Testing Backups

Always test your backups by:

1. Attempting restoration on a test environment
2. Verifying file integrity of compressed archives
3. Testing database imports for corruption
4. Checking backup file sizes for consistency

## Best Practices

1. **Regular testing**: Test backup restoration procedures monthly
2. **Multiple locations**: Store backups in multiple locations (local + remote)
3. **Version control**: Keep backup scripts in version control
4. **Documentation**: Document your specific backup procedures and schedules
5. **Monitoring**: Set up alerts for backup failures
6. **Retention policy**: Implement appropriate backup retention policies

## Integration with Trellis

For Trellis-specific considerations:

1. **Vault files**: Back up Trellis vault files containing sensitive configuration
2. **SSL certificates**: Include SSL certificates in file backups
3. **Nginx configuration**: Back up custom Nginx configurations
4. **Environment files**: Include all environment-specific configuration files

This backup strategy ensures your Trellis-managed WordPress sites are protected with reliable, automated backup procedures.