# WordPress Page Creation Guide - Trellis/Bedrock

Complete guide for creating WordPress pages on Trellis VM (local development) and production servers using WP-CLI and Gutenberg blocks.

**Last Updated:** November 25, 2025
**Environment:** Trellis VM (Lima-based) with Bedrock/WordPress
**Compatibility:** Trellis 1.x, Bedrock, WordPress 6.x+

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development (Trellis VM)](#local-development-trellis-vm)
3. [Production Deployment](#production-deployment)
4. [Content Preparation](#content-preparation)
5. [Common Issues & Solutions](#common-issues--solutions)
6. [Best Practices](#best-practices)

---

## Prerequisites

### Required Tools
- **Trellis CLI** - For VM access
- **WP-CLI** - WordPress command-line interface (available in VM)
- **Text Editor** - For preparing block content

### Required Access
- **Local:** Trellis VM running at project location
- **Production:** SSH access to production server
- **Permissions:** WordPress admin or WP-CLI access

### Project Structure
```
~/code/example.com/
├── site/                    # Bedrock WordPress installation
│   └── web/app/
│       ├── themes/your-theme/  # Custom Sage theme
│       └── plugins/your-patterns-plugin/ # Block patterns plugin (optional)
└── trellis/                 # Trellis configuration
```

**Note:** Replace `example.com` with your actual domain throughout this guide.

---

## Local Development (Trellis VM)

### Step 1: Prepare Block Content

Create an HTML file with Gutenberg block markup:

```bash
# Location: Can be anywhere, will be copied to site directory
nano ~/code/seo-strategy/about-page-content.html
```

**Content Structure:**
- Use WordPress Gutenberg block comments (`<!-- wp:block-name -->`)
- Follow your theme's block patterns for consistency (if using a patterns plugin)
- Include proper spacing variables (`var:preset|spacing|*`)
- Use your theme's color palette (check `theme.json` for available colors)

**Example Block Pattern:**
```html
<!-- wp:group {"align":"full","backgroundColor":"base","style":{"spacing":{"padding":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|60"}}},"layout":{"type":"default"}} -->
<div class="wp-block-group alignfull has-base-background-color has-background" style="padding-top:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--60)">
    <!-- wp:heading {"textAlign":"center","level":1,"fontSize":"5xl"} -->
    <h1 class="wp-block-heading has-text-align-center has-5-xl-font-size">Your Heading</h1>
    <!-- /wp:heading -->
</div>
<!-- /wp:group -->
```

### Step 2: Check for Conflicting Slugs

Before creating the page, verify the desired slug is available:

```bash
cd ~/code/example.com/trellis
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post list --name=about --post_type=any --path=web/wp \
  --fields=ID,post_type,post_title,post_name,post_status
```

**Note:** Replace `example.com` with your actual domain name.

**Common Conflicts:**
- **Attachments** with the same slug (e.g., `about` from uploaded images)
- **Draft pages** that were previously created
- **Trashed posts** that haven't been permanently deleted

**Resolution:**
```bash
# Delete conflicting attachments/posts (use actual IDs from above command)
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post delete 2366 1366 --force --path=web/wp
```

### Step 3: Copy Content File to Accessible Location

The Trellis VM can access files in the synced project directory:

```bash
# Copy content to site directory (accessible by VM at /srv/www/example.com/current/)
cp ~/path/to/your/about-page-content.html \
   ~/code/example.com/site/about-page-content.html
```

**Why this step?**
- Lima (Trellis VM) syncs your project directory (e.g., `~/code/example.com/`) to `/srv/www/example.com/current/` inside the VM
- Files outside this directory are not accessible by the VM
- Automatic real-time sync means no manual file transfer needed

### Step 4: Create the Page via WP-CLI

Use WP-CLI to create the page from the VM:

```bash
cd ~/code/example.com/trellis

# Method: Read file in VM and create page
trellis vm shell --workdir /srv/www/example.com/current -- bash -c '
CONTENT=$(cat /srv/www/example.com/current/site/about-page-content.html)
wp post create \
  --post_type=page \
  --post_title="About" \
  --post_name="about" \
  --post_status=publish \
  --post_content="$CONTENT" \
  --path=web/wp
'
```

**Command Breakdown:**
- `trellis vm shell` - Access Trellis VM
- `--workdir` - Set working directory in VM
- `bash -c` - Execute bash commands in VM
- `CONTENT=$(cat ...)` - Read file content into variable
- `wp post create` - Create new WordPress post/page
- `--post_type=page` - Create a page (not post)
- `--post_status=publish` - Publish immediately
- `--path=web/wp` - WordPress installation path in Bedrock

**Expected Output:**
```
Success: Created post 12306.
```

### Step 5: Verify Page Creation

```bash
# Check page details (replace 12306 with your actual page ID)
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post get 12306 --path=web/wp \
  --fields=ID,post_title,post_name,post_status,post_type

# Verify content was saved correctly (search for a unique phrase from your content)
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post get 12306 --path=web/wp --field=post_content | grep -o "Your Unique Phrase"
```

### Step 6: Update Slug (If Needed)

If WordPress created the page with an auto-incremented slug (e.g., `about-2`):

```bash
# Update to correct slug after removing conflicts
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post update 12306 --post_name=about --path=web/wp
```

### Step 7: Flush Cache & Test

```bash
# Flush WordPress cache
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp cache flush --path=web/wp

# Test page in browser (replace example.test with your local domain)
open https://example.test/about/
```

### Step 8: Clean Up

```bash
# Remove temporary content file
rm ~/code/example.com/site/about-page-content.html
```

---

## Production Deployment

### Option 1: Recreate Page on Production

**Step 1: Prepare Content**
```bash
# Copy content file to server-accessible location
# Replace web@example.com with your actual server user and domain
scp ~/path/to/your/about-page-content.html web@example.com:/tmp/
```

**Step 2: Create Page**
```bash
# SSH to production (replace with your actual server)
ssh web@example.com
cd /srv/www/example.com/current

# Create page
CONTENT=$(cat /tmp/about-page-content.html)
wp post create \
  --post_type=page \
  --post_title="About" \
  --post_name="about" \
  --post_status=publish \
  --post_content="$CONTENT" \
  --path=web/wp

# Clean up
rm /tmp/about-page-content.html
```

**Step 3: Verify**
```bash
# Check page was created
wp post list --post_type=page --name=about --path=web/wp \
  --fields=ID,post_title,post_name,post_status

# Flush cache
wp cache flush --path=web/wp

# Test in browser (replace with your actual domain)
curl -I https://example.com/about/
```

### Option 2: Export/Import via Database

**Step 1: Export Page from Development**
```bash
# Export specific page
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post list --post_type=page --name=about --path=web/wp \
  --format=json > about-page-export.json
```

**Step 2: Recreate on Production**
```bash
# Read JSON and create matching page on production
ssh web@example.com "cd /srv/www/example.com/current && \
  wp post create --post_type=page --post_title='About' \
  --post_name='about' --post_status=publish \
  --post_content='<content here>' --path=web/wp"
```

### Option 3: WordPress Export/Import (WXR)

**For multiple pages or complex content:**

```bash
# Local: Export page (replace 12306 with your actual page ID)
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp export --path=web/wp --post__in=12306 --dir=/tmp

# Copy to production
scp web@example.com:/tmp/export.xml /tmp/
ssh web@example.com
wp import /tmp/export.xml --path=/srv/www/example.com/current/web/wp --authors=skip
```

---

## Content Preparation

### Using Block Patterns Plugin (Optional)

If your project includes a custom block patterns plugin:

**Location:** `~/code/example.com/site/web/app/plugins/your-patterns-plugin/patterns/`

**Common Pattern Types:**
- Hero sections with buttons
- Feature grids and layouts
- Testimonials and reviews
- Team member grids
- Pricing tables
- Contact information blocks
- Call-to-action sections

**Pattern Structure:**
```php
return array(
    'title'   => 'Pattern Name',
    'content' => '<!-- wp:group -->...'
);
```

**Note:** Pattern availability depends on your specific theme and plugins.

### Block Content Guidelines

**1. No Fixed Font Sizes**
```html
<!-- ❌ BAD -->
<h1 style="font-size:3rem">Heading</h1>

<!-- ✅ GOOD -->
<h1 class="wp-block-heading has-5-xl-font-size">Heading</h1>
```

**2. Use Theme Color Palette**
```html
<!-- ✅ Use named colors -->
textColor="primary"
backgroundColor="base"

<!-- ❌ Avoid inline colors -->
style="color:#ff6b35"
```

**3. Use Spacing Variables**
```html
<!-- ✅ Use preset spacing -->
style="padding-top:var(--wp--preset--spacing--60)"

<!-- ❌ Avoid fixed spacing -->
style="padding-top:60px"
```

**4. Responsive Design**
- Use `alignfull` for full-width sections
- Use `alignwide` for constrained wide sections
- Rely on theme's responsive breakpoints

### SEO Considerations

**Page Title:**
- Keep under 60 characters
- Include primary keyword
- Consider your SEO plugin's title suffix (e.g., "| Your Site Name")

**Meta Description:**
- Maximum 155 characters
- Set via your SEO plugin's meta box (e.g., The SEO Framework, Yoast, Rank Math)
- Focus on your unique value proposition

**Heading Structure:**
- One H1 per page (page title)
- Use H2 for main sections
- Use H3 for subsections
- Maintain proper hierarchy

---

## Common Issues & Solutions

### Issue 1: Slug Already Exists

**Symptom:** Page created with slug `about-2` instead of `about`

**Cause:** Another post/attachment already uses the `about` slug

**Solution:**
```bash
# Find conflicting posts
wp post list --name=about --post_type=any --path=web/wp

# Delete conflicts
wp post delete <ID> --force --path=web/wp

# Update page slug
wp post update <PAGE_ID> --post_name=about --path=web/wp
```

### Issue 2: Content Not Displaying

**Symptom:** Page shows blank or incorrect content

**Causes:**
1. Cache not flushed
2. File content not properly escaped
3. Block markup errors

**Solutions:**
```bash
# Flush all caches
wp cache flush --path=web/wp

# Check content was saved
wp post get <ID> --path=web/wp --field=post_content | head -20

# Validate block markup
wp block validate <ID> --path=web/wp
```

### Issue 3: Cannot Run WP-CLI from Host

**Symptom:** `Error: Can't read wp-config.php file`

**Cause:** Local MariaDB/MySQL running on port 3306 conflicts with VM

**Solution:** Always run WP-CLI commands from within Trellis VM:
```bash
# ✅ CORRECT: Run in VM
trellis vm shell --workdir /srv/www/example.com/current -- wp <command>

# ❌ WRONG: Run on host
wp <command> --path=~/code/example.com/site/web/wp
```

### Issue 4: File Sync Issues

**Symptom:** Changes not appearing in VM

**Cause:** Lima file sync delay or WordPress cache

**Solutions:**
```bash
# Check if file exists in VM
trellis vm shell -- ls -la /srv/www/example.com/current/site/

# Flush WordPress cache
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp cache flush --path=web/wp

# Hard refresh browser (Cmd+Shift+R on Mac, Ctrl+Shift+R on Linux/Windows)
```

### Issue 5: Command Substitution Not Working

**Symptom:** Content shows literal `$(cat ...)` instead of file contents

**Cause:** Shell escaping issues with nested quotes

**Solution:** Use proper quoting in bash:
```bash
# ✅ CORRECT: Single quotes for outer bash -c, double for inner
bash -c 'CONTENT=$(cat file.html) && wp post create --post_content="$CONTENT"'

# ❌ WRONG: Double quotes everywhere
bash -c "CONTENT=$(cat file.html) && wp post create --post_content=\"$CONTENT\""
```

---

## Best Practices

### Development Workflow

1. **Always work locally first**
   - Test on Trellis VM (e.g., `https://example.test`)
   - Verify content displays correctly
   - Check responsive design at different viewports

2. **Version control content files**
   - Store block content in version control
   - Use descriptive filenames (`about-page-content.html`)
   - Document any custom blocks or patterns used

3. **Use patterns for consistency**
   - Leverage your theme's block patterns (if available)
   - Maintain consistent spacing and colors from your theme
   - Reuse existing blocks when possible

4. **Test before production**
   - Verify all links work
   - Check images display correctly
   - Test contact forms/CTAs
   - Validate schema markup

### Security Best Practices

1. **Avoid inline scripts**
   - Don't include `<script>` tags in content
   - Use theme/plugin for JavaScript functionality

2. **Sanitize user input**
   - Escape special characters in dynamic content
   - Use WordPress sanitization functions

3. **Limit permissions**
   - Use `web` user for WP-CLI on production
   - Don't use `root` for content operations

### Performance Optimization

1. **Optimize images before uploading**
   - Use WebP format
   - Compress to appropriate size
   - Include alt text for SEO

2. **Minimize inline styles**
   - Use theme classes instead of inline CSS
   - Rely on theme spacing/typography system

3. **Lazy load off-screen content**
   - Use native lazy loading for images
   - Defer non-critical content

### SEO Optimization

1. **Set page metadata**
   - Title tag (via your SEO plugin)
   - Meta description (155 chars max)
   - Open Graph tags (if supported by your SEO plugin)

2. **Optimize heading structure**
   - One H1 per page
   - Logical H2-H6 hierarchy
   - Include target keywords

3. **Add internal links**
   - Link to relevant service pages
   - Link to blog posts
   - Use descriptive anchor text

4. **Schema markup** (if implemented)
   - Verify schema presence with your schema validation tools
   - Add enhanced Organization schema for About page
   - Include BreadcrumbList for navigation

---

## Example: Complete About Page Creation

### Full Command Sequence

```bash
# 1. Navigate to project
cd ~/code/example.com/trellis

# 2. Check for conflicts
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post list --name=about --post_type=any --path=web/wp \
  --fields=ID,post_type,post_title,post_name

# 3. Delete conflicts if found (use actual IDs from step 2)
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post delete 2366 1366 --force --path=web/wp

# 4. Copy content file
cp ~/path/to/your/about-page-content.html \
   ~/code/example.com/site/about-page-content.html

# 5. Create page
trellis vm shell --workdir /srv/www/example.com/current -- bash -c '
CONTENT=$(cat /srv/www/example.com/current/site/about-page-content.html)
wp post create \
  --post_type=page \
  --post_title="About" \
  --post_name="about" \
  --post_status=publish \
  --post_content="$CONTENT" \
  --path=web/wp
'

# 6. Verify creation (replace 12306 with the ID from step 5 output)
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp post get 12306 --path=web/wp \
  --fields=ID,post_title,post_name,post_status

# 7. Flush cache
trellis vm shell --workdir /srv/www/example.com/current -- \
  wp cache flush --path=web/wp

# 8. Clean up
rm ~/code/example.com/site/about-page-content.html

# 9. Test in browser (replace example.test with your local domain)
open https://example.test/about/
```

---

## Related Documentation

- **Trellis Documentation:** [roots.io/trellis](https://roots.io/trellis/)
- **Bedrock Documentation:** [roots.io/bedrock](https://roots.io/bedrock/)
- **WP-CLI Documentation:** [wp-cli.org](https://wp-cli.org/)
- **WordPress Block Editor:** [wordpress.org/gutenberg](https://wordpress.org/gutenberg/)
- **Your Project README:** Check your project's `CLAUDE.md` or `README.md` for project-specific instructions

---

## Quick Reference

### Key Paths

| Description | Local Path | VM Path |
|-------------|------------|---------|
| Project Root | `~/code/example.com` | `/srv/www/example.com/current` |
| WordPress | `site/web/wp` | `web/wp` |
| Theme | `site/web/app/themes/your-theme` | `web/app/themes/your-theme` |
| Plugins | `site/web/app/plugins` | `web/app/plugins` |
| Uploads | `site/web/app/uploads` | `web/app/uploads` |

**Note:** Replace `example.com` and `your-theme` with your actual domain and theme name.

### Essential Commands

```bash
# Access VM shell
trellis vm shell

# Run WP-CLI command
trellis vm shell --workdir /srv/www/example.com/current -- wp <command> --path=web/wp

# List pages
wp post list --post_type=page --path=web/wp

# Get page details
wp post get <ID> --path=web/wp

# Update page
wp post update <ID> --post_title="New Title" --path=web/wp

# Delete page
wp post delete <ID> --force --path=web/wp

# Flush cache
wp cache flush --path=web/wp
```

---

**Document Version:** 1.0
**Created:** November 25, 2025
**Author:** Claude Code Documentation
**Status:** Production Ready
