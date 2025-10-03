# Provisioning

## Navigate to trellis directory

```bash
cd trellis
```

## Provision development environment

```bash
ansible-playbook dev.yml
```

## Deploy to staging/production

```bash
ansible-playbook deploy.yml -e env=staging
ansible-playbook deploy.yml -e env=production
```

## Re-provision production with specific tags

Use `trellis provision` command instead of `ansible-playbook server.yml`:

```bash
trellis provision --tags php,nginx,composer production
```

## Full server provisioning

Use sparingly:

```bash
trellis provision production
```

## PHP Version Upgrade Process

1. Update `php_version` in `trellis/group_vars/all/main.yml`
2. Run with `php`, `nginx`, `wordpress-setup`, `users`, and `memcached` tags:

```bash
trellis provision --tags php,nginx,wordpress-setup,users,memcached production
```

**Why these tags are required:**
- `php` - Installs new PHP version and extensions
- `nginx` - Updates Nginx configuration for new PHP-FPM socket
- `wordpress-setup` - Creates `/etc/php/X.X/fpm/pool.d/wordpress.conf`
- `users` - **Critical**: Regenerates sudoers with new PHP version for passwordless `php-fpm reload`
- `memcached` - Installs PHP version-specific memcached extension (e.g., `php8.3-memcached`)

**Note:** Without the `users` tag, deployments will fail when trying to reload PHP-FPM because the sudoers configuration still references the old PHP version.
