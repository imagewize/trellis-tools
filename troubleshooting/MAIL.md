# Mail Configuration Issues

## Table of Contents

- [Problem](#problem)
- [Symptoms](#symptoms)
- [Diagnosis](#diagnosis)
- [Solution](#solution)
- [Prevention](#prevention)

## Problem

After a Trellis upgrade, mail functionality stopped working because the main configuration file `trellis/group_vars/all/mail.yml` was overwritten with default settings.

## Symptoms

System logs show repeated SMTP connection failures with error messages like:

- `Unable to locate smtp.example.com`
- `Cannot open smtp.example.com:587`
- `MAIL (mailed X bytes of output but got status 0x0001 from MTA)`

## Diagnosis

### Check System Logs

SSH into the server and examine recent logs for mail-related errors:

```bash
ssh root@domain.com "journalctl -b | tail -50"
```

### Key Error Messages to Look For

```
sSMTP[12502]: Unable to locate smtp.example.com
cron[12502]: sendmail: Cannot open smtp.example.com:587
sSMTP[12502]: Cannot open smtp.example.com:587
CRON[12499]: (root) MAIL (mailed 65 bytes of output but got status 0x0001 from MTA
```

### Verify Mail Configuration

Check if `trellis/group_vars/all/mail.yml` contains default placeholder values instead of actual SMTP credentials.

## Solution

### Restore Proper Mail Settings

Edit `trellis/group_vars/all/mail.yml` with your actual SMTP configuration:

```yml
# Documentation: https://roots.io/trellis/docs/mail/
mail_smtp_server: smtp.yourdomain.com:587
mail_admin: admin@yourdomain.com
mail_hostname: yourdomain.com
mail_user: your_smtp_username
mail_password: "{{ vault_mail_password }}" # Define this variable in group_vars/all/vault.yml
```

### Set Vault Password

Ensure the SMTP password is securely stored in `trellis/group_vars/all/vault.yml`:

```yml
vault_mail_password: your_actual_smtp_password
```

### Re-provision Server

Apply the updated mail configuration:

```bash
trellis provision production
```

## Prevention

### Before Upgrading Trellis

1. **Backup configuration files** - Especially `group_vars/all/mail.yml`
2. **Review upgrade notes** - Check if configuration file formats have changed
3. **Use version control** - Commit current configuration before upgrading
4. **Document custom settings** - Keep a record of non-default values

### After Upgrading Trellis

1. **Review configuration files** - Check for overwritten or reset values
2. **Compare with backup** - Verify custom settings were preserved
3. **Test mail functionality** - Send test emails after provisioning
4. **Monitor logs** - Watch for SMTP errors in the first 24 hours

### Recommended Tools

Check mail configuration on remote server:

```bash
ssh root@domain.com "grep -A 5 'mail_smtp_server' /etc/ssmtp/ssmtp.conf"
```

Test mail sending:

```bash
echo "Test message" | mail -s "Test Subject" your-email@example.com
```