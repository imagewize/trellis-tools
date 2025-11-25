# Content Creation Guide for WordPress

This guide covers techniques for creating and managing WordPress content using WP-CLI, block patterns, and shell scripting. These tools are particularly useful for Trellis/Bedrock deployments where you need to automate content creation or bulk-update pages.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Understanding WordPress Block Patterns](#understanding-wordpress-block-patterns)
- [Creating Content with WP-CLI](#creating-content-with-wp-cli)
- [Updating Posts with Block Pattern HTML](#updating-posts-with-block-pattern-html)
- [Complete Workflow Examples](#complete-workflow-examples)
- [Pattern Categories Reference](#pattern-categories-reference)
- [Tips and Best Practices](#tips-and-best-practices)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)
- [Related Guides](#related-guides)

## Prerequisites

### Required Tools

- **WP-CLI**: WordPress command-line interface
- **Trellis**: For remote server management (if deploying remotely)
- **SSH Access**: To your WordPress server (for remote operations)

### WP-CLI Installation

WP-CLI is typically pre-installed in Trellis/Bedrock environments. To verify:

```bash
# Local development
wp --version

# Remote via Trellis
trellis vm shell --workdir /srv/www/example.com/current -- wp --version --path=web/wp
```

## Understanding WordPress Block Patterns

WordPress block patterns are pre-designed block layouts that can be inserted into pages. They use the WordPress block markup format (HTML comments with JSON configuration).

### Block Pattern Structure

```html
<!-- wp:pattern {"slug":"theme-name/pattern-slug"} /-->
```

### Common Block Elements

```html
<!-- Headings -->
<!-- wp:heading {"textAlign":"center","fontSize":"xxx-large"} -->
<h2 class="wp-block-heading has-text-align-center has-xxx-large-font-size">Your Heading</h2>
<!-- /wp:heading -->

<!-- Paragraphs -->
<!-- wp:paragraph {"align":"center","fontSize":"medium"} -->
<p class="has-text-align-center has-medium-font-size">Your content here</p>
<!-- /wp:paragraph -->

<!-- Columns -->
<!-- wp:columns {"align":"wide"} -->
<div class="wp-block-columns alignwide">
<!-- wp:column -->
<div class="wp-block-column">
  <!-- Content here -->
</div>
<!-- /wp:column -->
</div>
<!-- /wp:columns -->

<!-- Groups (Container blocks) -->
<!-- wp:group {"align":"full","backgroundColor":"base"} -->
<div class="wp-block-group alignfull has-base-background-color has-background">
  <!-- Content here -->
</div>
<!-- /wp:group -->

<!-- Spacer -->
<!-- wp:spacer {"height":"40px"} -->
<div style="height:40px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->
```

## Creating Content with WP-CLI

### Basic Post/Page Operations

```bash
# Create a new page
wp post create --post_type=page --post_title="My Page" --post_status=publish --path=web/wp

# Update existing post (by ID)
wp post update 100 --post_title="Updated Title" --path=web/wp

# Update post content
wp post update 100 --post_content="<p>New content</p>" --path=web/wp

# List all pages
wp post list --post_type=page --path=web/wp

# Get post details
wp post get 100 --path=web/wp
```

### Remote Operations via Trellis

```bash
# Access your remote site via Trellis
cd trellis

# Execute WP-CLI commands on remote server
trellis vm shell --workdir /srv/www/example.com/current -- wp post list --post_type=page --path=web/wp

# Or enter interactive shell
trellis vm shell --workdir /srv/www/example.com/current
# Then run: wp post list --post_type=page --path=web/wp
```

## Updating Posts with Block Pattern HTML

### Method 1: Direct WP-CLI Update (Simple Content)

For simple content updates, you can pass the HTML directly:

```bash
# Create a temporary file with your content
cat > /tmp/page-content.html << 'EOF'
<!-- wp:heading {"textAlign":"center"} -->
<h2 class="wp-block-heading has-text-align-center">Welcome</h2>
<!-- /wp:heading -->

<!-- wp:paragraph {"align":"center"} -->
<p class="has-text-align-center">This is simple content.</p>
<!-- /wp:paragraph -->
EOF

# Update the post (local)
CONTENT=$(cat /tmp/page-content.html)
wp post update 100 --post_content="$CONTENT" --path=web/wp
```

### Method 2: Using Python for Complex Content

For complex content with special characters, use Python to properly escape the content:

```bash
# Create your content file
cat > /tmp/page-content.html << 'EOF'
<!-- Your complex HTML here -->
EOF

# Use Python to escape and update
cd /path/to/your/project && cat /tmp/page-content.html | python3 << 'PYEOF'
import sys
import subprocess

# Read the HTML content
content = sys.stdin.read()

# Escape content for shell
content_escaped = content.replace("'", "'\\''")

# Use WP-CLI to update the post
cmd = f"wp post update 100 --post_content='{content_escaped}' --path=web/wp"
subprocess.run(cmd, shell=True, executable='/bin/bash')
PYEOF
```

### Method 3: Via Trellis SSH (Remote Server)

```bash
# Create content file locally
cat > /tmp/page-content.html << 'EOF'
<!-- Your content here -->
EOF

# Copy to server and update (via Trellis)
cd trellis && trellis vm shell --workdir /srv/www/example.com/current << 'VMEOF'
CONTENT=$(cat /tmp/page-content.html)
wp post update 100 --post_content="$CONTENT" --path=web/wp
VMEOF
```

## Complete Workflow Examples

### Example 1: Creating a Pattern Showcase Page

This example creates a comprehensive page showcasing different block pattern categories:

```bash
# Step 1: Create the HTML content file
cat > /tmp/patterns-page.html << 'EOF'
<!-- wp:pattern {"slug":"moiraine/hero-call-to-action-buttons-light"} /-->

<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|xxx-large","bottom":"var:preset|spacing|xxx-large"}}},"backgroundColor":"base","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-base-background-color has-background" style="padding-top:var(--wp--preset--spacing--xxx-large);padding-bottom:var(--wp--preset--spacing--xxx-large)">
<!-- wp:heading {"textAlign":"center","fontSize":"xxx-large"} -->
<h2 class="wp-block-heading has-text-align-center has-xxx-large-font-size">Browse Patterns by Category</h2>
<!-- /wp:heading -->

<!-- wp:paragraph {"align":"center","fontSize":"medium"} -->
<p class="has-text-align-center has-medium-font-size">Explore professionally designed patterns organized by use case. Every pattern is performance-optimized, fully responsive, and ready to customize.</p>
<!-- /wp:paragraph -->

<!-- wp:spacer {"height":"40px"} -->
<div style="height:40px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:columns {"align":"wide"} -->
<div class="wp-block-columns alignwide">
<!-- wp:column -->
<div class="wp-block-column">
<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Hero Sections</h3>
<!-- /wp:heading -->
<!-- wp:paragraph -->
<p>10+ hero patterns for powerful first impressions. Full-width designs with CTAs, backgrounds, and image options.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column">
<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Content Layouts</h3>
<!-- /wp:heading -->
<!-- wp:paragraph -->
<p>25+ versatile patterns including text and image combinations, columns, feature boxes, and content grids.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column">
<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Testimonials</h3>
<!-- /wp:heading -->
<!-- wp:paragraph -->
<p>15+ social proof patterns with customer testimonials, logos, team members, and review displays.</p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:column -->
</div>
<!-- /wp:columns -->
</div>
<!-- /wp:group -->

<!-- wp:pattern {"slug":"moiraine/hero-dark"} /-->
<!-- wp:pattern {"slug":"moiraine/hero-light"} /-->
EOF

# Step 2: Update the post (replace 100 with your post ID)
CONTENT=$(cat /tmp/patterns-page.html)
wp post update 100 --post_content="$CONTENT" --path=web/wp

# Step 3: Verify the update
wp post get 100 --path=web/wp
```

### Example 2: Batch Update Multiple Pages

```bash
#!/bin/bash

# Array of page IDs to update
PAGE_IDS=(100 101 102)

# Template content
TEMPLATE='<!-- wp:heading {"textAlign":"center"} -->
<h2 class="wp-block-heading has-text-align-center">Updated Content</h2>
<!-- /wp:heading -->'

# Update each page
for page_id in "${PAGE_IDS[@]}"; do
  echo "Updating page $page_id..."
  wp post update "$page_id" --post_content="$TEMPLATE" --path=web/wp
  echo "Page $page_id updated successfully"
done
```

### Example 3: Create New Page with Pattern Content

```bash
#!/bin/bash

# Create content file
cat > /tmp/new-page-content.html << 'EOF'
<!-- wp:pattern {"slug":"moiraine/hero-light"} /-->
<!-- wp:pattern {"slug":"moiraine/text-and-image-left"} /-->
<!-- wp:pattern {"slug":"moiraine/testimonials-and-logos"} /-->
EOF

# Read content
CONTENT=$(cat /tmp/new-page-content.html)

# Create new page
wp post create \
  --post_type=page \
  --post_title="New Landing Page" \
  --post_status=publish \
  --post_content="$CONTENT" \
  --path=web/wp
```

### Example 4: Remote Update via Trellis

```bash
#!/bin/bash

# Create content locally
cat > /tmp/remote-page.html << 'EOF'
<!-- wp:pattern {"slug":"moiraine/pricing-table"} /-->
<!-- wp:pattern {"slug":"moiraine/faq"} /-->
EOF

# Update on remote server via Trellis
cd /path/to/trellis && trellis vm shell --workdir /srv/www/example.com/current << 'VMEOF'
CONTENT=$(cat << 'CONTENT_EOF'
<!-- wp:pattern {"slug":"moiraine/pricing-table"} /-->
<!-- wp:pattern {"slug":"moiraine/faq"} /-->
CONTENT_EOF
)
wp post update 100 --post_content="$CONTENT" --path=web/wp
VMEOF
```

## Pattern Categories Reference

### Hero Sections
Full-width introductory sections at the top of pages:
- `hero-dark`: Dark background hero with large text
- `hero-light`: Light background hero with large text
- `hero-call-to-action-buttons-light`: Hero with CTA buttons on light background

**Use cases**: Landing pages, homepage, product pages

### Content Layouts
Versatile patterns for presenting information:
- `text-and-image-left`: Text content with image on left side
- `text-and-image-right`: Text content with image on right side
- `three-column-text`: Three-column text layout
- `feature-boxes-with-button`: Feature boxes with CTA buttons
- `card-details`: Card-style content presentation

**Use cases**: About pages, service descriptions, feature highlights

### Testimonials & Social Proof
Build trust with customer feedback:
- `testimonials-and-logos`: Customer testimonials with company logos
- `testimonials-with-big-text`: Large format testimonials
- `numbers`: Statistics and number highlights

**Use cases**: Social proof sections, case studies, trust building

### Pricing & CTAs
Conversion-focused patterns:
- `pricing-table`: Structured pricing comparison table
- `text-call-to-action-buttons`: CTA section with buttons

**Use cases**: Pricing pages, product pages, conversion points

### Blog & Portfolio
Content display patterns:
- `blog-post-columns`: Multi-column blog post layout
- `card-details`: Portfolio-style card grid

**Use cases**: Blog archives, portfolio pages, content listings

### FAQ & Support
Help and information patterns:
- `faq`: Accordion-style FAQ section

**Use cases**: Support pages, help documentation, Q&A sections

## Tips and Best Practices

### Content Escaping

1. **Always use heredocs with quoted delimiters** to prevent variable expansion:
   ```bash
   cat > file.html << 'EOF'  # Note the quotes around EOF
   Content here
   EOF
   ```

2. **For complex content**, use Python's escaping method (shown in Method 2 above)

3. **Test locally first** before updating production content

### Working with Patterns

1. **List available patterns**:
   ```bash
   wp post list --post_type=wp_block --path=web/wp
   ```

2. **Export existing page content** to see pattern structure:
   ```bash
   wp post get 100 --field=post_content --path=web/wp > exported-content.html
   ```

3. **Validate pattern slugs** by checking your theme's patterns directory

### Automation Considerations

1. **Always backup** before bulk updates:
   ```bash
   wp db export backup.sql --path=web/wp
   ```

2. **Use post IDs** instead of slugs for more reliable updates

3. **Log your operations** for audit trails:
   ```bash
   wp post update 100 --post_content="$CONTENT" --path=web/wp 2>&1 | tee update.log
   ```

4. **Preview changes** by updating post status to 'draft' first:
   ```bash
   wp post update 100 --post_status=draft --post_content="$CONTENT" --path=web/wp
   ```

### Performance Tips

1. **Minimize pattern nesting** - Each pattern adds rendering overhead
2. **Optimize images** referenced in patterns (see [../image-optimization/README.md](../image-optimization/README.md))
3. **Use caching** - Ensure your page caching is configured properly
4. **Test mobile rendering** - Block patterns should be fully responsive

## Troubleshooting

### Common Issues

**Issue**: Content not updating
```bash
# Clear WordPress cache
wp cache flush --path=web/wp

# Clear object cache
wp transient delete --all --path=web/wp
```

**Issue**: Special characters causing problems
- Use the Python escaping method (Method 2)
- Or save content to file and use `--post_content="$(cat file.html)"`

**Issue**: Pattern not rendering
- Verify pattern slug exists in your theme
- Check that theme supports the pattern category
- Ensure all required blocks are registered

### Debugging

```bash
# Enable WordPress debug mode
wp config set WP_DEBUG true --path=web/wp

# Check for errors in logs
tail -f /path/to/wordpress/wp-content/debug.log

# Validate post content
wp post get 100 --field=post_content --path=web/wp | head -50
```

## Additional Resources

- [WP-CLI Documentation](https://wp-cli.org/)
- [WordPress Block Editor Handbook](https://developer.wordpress.org/block-editor/)
- [Block Pattern Directory](https://wordpress.org/patterns/)
- [Trellis Documentation](https://roots.io/trellis/docs/)

## Related Guides

- [Page Creation Guide](PAGE-CREATION.md) - Complete step-by-step guide for creating WordPress pages locally and in production
- [Image Optimization](../image-optimization/README.md) - Optimize images used in your patterns
- [Migration Guide](../migration/README.md) - Migrating content between environments
