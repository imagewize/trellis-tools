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
2. Run with `php`, `nginx`, and `wordpress-setup` tags (avoids 502 errors):

```bash
trellis provision --tags php,nginx,wordpress-setup production
```

This installs PHP, updates Nginx config, and creates the WordPress PHP-FPM pool. The `wordpress-setup` tag creates `/etc/php/X.X/fpm/pool.d/wordpress.conf`.
