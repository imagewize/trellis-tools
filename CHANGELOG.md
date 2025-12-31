# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.16.3] - 2025-12-31

### Changed
- Enhanced rsync-theme.sh with additional exclusions for cleaner theme repository syncing
- Added `create-pr.sh` to exclusion list (Trellis-tools specific script, not needed in theme repos)
- Added `.distignore` to exclusion list (WordPress.org plugin/theme deployment file)
- Updated example paths from 'nynaeve' theme to 'elayne' theme for better documentation clarity

## [1.16.2] - 2025-12-31

### Added
- Critical URL sanitization section in PAGE-CREATION.md explaining hardcoded pattern URLs issue
- Pre-deployment URL audit commands for detecting local development URLs in production
- Step-by-step URL search-replace workflow with database backup procedures
- Browser verification steps for mixed content warnings
- CLAUDE.md section explaining how WordPress pattern URLs get hardcoded in database
- Search-replace examples for both single-site and multisite WordPress installations

### Changed
- Enhanced PAGE-CREATION.md with "CRITICAL: URL Sanitization Before Production" section
- Updated CLAUDE.md "URL Management in Database Operations" with pattern URL hardcoding warning
- Added cross-reference between CLAUDE.md and PAGE-CREATION.md for URL sanitization workflows

## [1.16.1] - 2025-12-30

### Changed
- Updated PROJECT-SETUP.md to use HTTP by default for local development instead of HTTPS
- Changed `WP_HOME` example from `https://yourproject.test` to `http://yourproject.test` for simpler local setup
- Updated all URL examples throughout the guide to use HTTP (with notes on HTTPS if SSL is enabled)
- Enhanced database pull section with URL search-replace guidance based on local SSL configuration
- Added dedicated multisite URL update section with WP-CLI `--network` flag examples
- Expanded troubleshooting section with new entries for 500 errors, WP-CLI autoloader issues, and SSH host key verification
- Added critical theme setup instructions after database pull (Composer/NPM install and build steps)
- Enhanced verification checklist to include theme dependency and asset build verification
- Added method 2 for direct rsync file sync when Ansible playbooks fail
- Updated quick reference commands to include theme setup workflow

### Added
- Multisite network URL update documentation with WP-CLI network commands
- Theme setup section explaining why Composer/NPM builds are required after database pulls
- Alternative MySQL-only commands for multisite URL updates (with warnings about limitations)
- SSH known_hosts configuration examples for production server access
- Theme asset build verification steps in checklist
- Explanation of Lima VM bidirectional file sync behavior

## [1.16.0] - 2025-12-30

### Added
- New project setup guide (provision/PROJECT-SETUP.md) for cloning and configuring existing Trellis/Bedrock projects
- Comprehensive project-specific documentation covering repository cloning, dependency installation, and VM provisioning
- Database and files setup options with Ansible playbook and direct VM command methods
- Theme development workflow with Vite dev server and HMR setup
- Production access configuration and deployment instructions
- Common project workflows including daily development, VM management, and WP-CLI operations
- Project-specific troubleshooting section with file sync, port conflicts, and SSL certificate issues
- Verification checklist for confirming successful project setup
- Quick reference commands for project management

### Changed
- **Breaking:** Refactored NEW-MACHINE.md to focus exclusively on macOS setup for Trellis development (machine setup only)
- Removed project-specific content from NEW-MACHINE.md (imagewize.com examples, ACF Pro setup, repository cloning)
- Generalized NEW-MACHINE.md with placeholder names (your-project, your-theme) for universal applicability
- Updated NEW-MACHINE.md to reference PROJECT-SETUP.md for next steps after machine configuration
- Updated main README.md to include both "New Machine Setup" and "Project Setup" guides with clear descriptions
- Reduced NEW-MACHINE.md from 804 lines to 318 lines for improved clarity and focus
- NEW-MACHINE.md now serves as a universal reference for any Trellis project

### Improved
- Clear separation of concerns between machine setup and project setup documentation
- Better navigation with cross-references between NEW-MACHINE.md and PROJECT-SETUP.md
- Enhanced reusability - PROJECT-SETUP.md serves as a template for any Trellis project
- Reduced confusion by eliminating the dual-purpose nature of the original NEW-MACHINE.md

## [1.15.0] - 2025-12-30

### Added
- Comprehensive new machine setup guide (provision/NEW-MACHINE.md) for setting up Trellis development environment
- Step-by-step instructions for installing required tools (Trellis CLI, Composer, PHP, Node.js, pnpm)
- Detailed explanation of host machine vs Trellis VM architecture and tool separation
- Complete workflow for cloning repository, installing dependencies, and configuring Trellis VM
- ACF Pro authentication setup instructions for Composer installation
- Database and files setup options (fresh installation vs production pull)
- Theme development workflow documentation with Vite dev server and HMR
- Production SSH access setup and deployment instructions
- Common development workflows (daily development, creating blocks, VM management)
- Troubleshooting section covering port conflicts, file sync, SSL certificates, and VM issues
- Verification checklist and quick reference commands
- Architecture diagrams explaining host/VM separation and development workflow
- Documentation on Lima VM vs Vagrant differences and file sync behavior

### Changed
- Updated main README.md to include "New Machine Setup" in tools table

## [1.14.0] - 2025-12-26

### Added
- New diagnostics directory with WordPress diagnostic tools for troubleshooting
- CLI transient diagnostic script (`diagnostic-transients.php`) for WP-CLI-based transient testing
- Browser-based transient debugger (`transient-debug-browser.php`) for web-accessible diagnostics
- Comprehensive diagnostic documentation covering transient storage, caching, and performance issues
- Security-conscious diagnostic tools with access controls and secret token protection
- Support for diagnosing external object cache conflicts (Redis, Memcached, LiteSpeed)
- Database performance metrics and wp_options table analysis
- Business hours logic testing for time-based cache lifetimes

### Changed
- Updated main README.md to include Diagnostics tool in tools table

## [1.13.1] - 2025-12-15

### Changed
- Updated `content-creation/PATTERN-REQUIREMENTS.md` to clarify metadata is recommended (not required), add guidance on block comment vs rendered HTML validation, extend checklist, and bump document version to 1.2

## [1.13.0] - 2025-12-15

### Added
- New `PATTERN-REQUIREMENTS.md` with comprehensive WordPress block pattern standards and validation checklist
- `AGENTS.md` contributor guide summarizing project structure, commands, coding conventions, and PR expectations

### Changed
- Reworked `content-creation/README.md` into a concise landing page with clear navigation to page creation workflows, pattern requirements, and automation scripts
- Moved the sample Gutenberg content file to `content-creation/examples/example-page-content.html` and updated references in `PAGE-CREATION.md`

## [1.12.2] - 2025-12-14

### Added
- New section "Adding Patterns to Existing Pages" to PAGE-CREATION.md with comprehensive examples
- Method 1: Update page via Trellis VM with heredoc pattern insertion
- Method 2: Batch add patterns by category for showcase pages
- Method 3: Finding pattern slugs from theme files
- Real-world Elayne theme pattern showcase examples (Heroes page and Patterns page)
- Tips for creating pattern showcase pages with consistent spacing and formatting
- Troubleshooting section for pattern rendering and content update issues
- VM-based content file creation examples using `/tmp` directory
- Multi-AI support in create-pr.sh with `--ai=claude|codex` option for flexible AI backend selection
- Interactive AI tool selection when both Claude and Codex CLIs are available
- Environment variable support for custom CLI command names (`CLAUDE_COMMAND`, `CODEX_COMMAND`)
- Support for custom AI CLI arguments via `CLAUDE_CLI_ARGS` and `CODEX_CLI_ARGS` environment variables

### Changed
- Updated PAGE-CREATION.md Table of Contents to include section 9
- Enhanced PAGE-CREATION.md with VM heredoc examples for multisite pattern updates
- Improved document version to 1.1 with updated timestamp (December 14, 2025)
- Refactored create-pr.sh option parsing to use `case` statement for better maintainability
- Enhanced AI CLI detection to check for both Claude and Codex availability
- Improved error handling in AI description generation with detailed error messages
- Updated CREATE-PR.md with multi-AI backend documentation and usage examples

## [1.12.1] - 2025-12-01

### Fixed
- **Critical:** Fixed timestamp filtering in monitoring scripts that prevented log analysis
- Fixed broken AWK timestamp parsing in `filter_recent_logs()` function (traffic-monitor.sh and security-monitor.sh)
- Fixed invalid octal number error when displaying hours 08 and 09 in traffic reports
- Replaced complex AWK-based timestamp filtering with simple tail-based line estimation (HOURS × 1000 requests)

### Changed
- Simplified log filtering approach using `tail -n` with estimated line count for better performance
- Updated monitoring scripts to process up to 50,000 most recent log lines (configurable based on time period)
- Improved monitoring script execution speed by eliminating per-line date command spawning

## [1.12.0] - 2025-12-01

### Added
- Comprehensive Nginx redirect configuration documentation and examples (redirects/)
- SEO redirect examples for fixing 404 errors and URL structure changes
- Generic redirect templates for common WordPress permalink migrations
- SSL/HTTPS redirect patterns for secure page enforcement
- Site-specific redirect example (imagewize.com/seo-redirects.conf.j2)
- Documentation covering Trellis nginx-includes deployment workflow
- Redirect best practices including exact path matching, regex patterns, and query string preservation
- Testing strategies for manual and automated redirect verification
- Performance considerations and optimization tips for large redirect sets
- Troubleshooting guide for common redirect issues (404s, loops, deployment problems)
- Methods for finding URLs to redirect using Google Search Console, server logs, and SEO tools

### Changed
- Updated main README.md to include Redirects tool in tools table

## [1.11.2] - 2025-11-29

### Fixed
- **Critical:** Fixed monitoring playbooks to use per-site log paths instead of global Nginx logs
- Updated all Ansible playbooks to default to `/srv/www/{{ site }}/logs/access.log` (Trellis standard)
- Updated traffic-report.yml, security-scan.yml, quick-status.yml to use `{{ project_root }}/logs/access.log`
- Updated setup-monitoring.yml wrapper scripts to use per-site logs in cron jobs
- Updated updown-webhook-handler.sh to default to per-site logs with environment variable override
- Updated shell scripts (traffic-monitor.sh, security-monitor.sh) to default to imagewize.com per-site logs

### Changed
- Added log path configuration documentation explaining per-site vs global logs
- Updated README.md with "Log File Locations" section and configuration override examples
- Updated QUICK-REFERENCE.md to show proper log path usage with `$LOG` variable
- All playbooks now support `-e log_file=/path/to/log` override for flexibility
- Modified all one-liner command examples to use configurable `$LOG` variable
- Shell scripts now default to `/srv/www/imagewize.com/logs/access.log` with examples for demo.imagewize.com and global logs

### Added
- Documentation explaining when to use per-site logs (default) vs global logs
- Examples showing how to override default log paths in Ansible playbooks
- Clear prerequisites about Trellis log configuration in both README and QUICK-REFERENCE
- Inline comments in shell scripts showing all available log path options

## [1.11.1] - 2025-11-29

### Changed
- Updated monitoring documentation to recommend root SSH access with key-based authentication
- Changed all monitoring examples from `web@example.com` to `root@example.com`
- Added "Alternative Access Methods" section with three options: sudo, adm group, and passwordless sudo
- Added security considerations emphasizing root password authentication must be disabled
- Updated QUICK-REFERENCE.md with root user examples and prerequisites note
- Clarified that root SSH access with keys is secure and practical for system administration tasks

## [1.11.0] - 2025-11-29

### Added
- Comprehensive monitoring tools for Nginx log analysis (monitoring/)
- Traffic analysis script (traffic-monitor.sh) with bot filtering, page views, unique visitors, and bandwidth tracking
- Security monitoring script (security-monitor.sh) for detecting bad actors, brute force attempts, SQL injection, and scanners
- Ansible playbooks for automated monitoring: quick-status.yml, traffic-report.yml, security-scan.yml, setup-monitoring.yml
- Automated monitoring setup with cron jobs for daily traffic reports and security scans
- updown.io webhook integration (updown-webhook-handler.sh and updown-webhook-receiver.php) for automatic log analysis on downtime
- Quick reference guide (QUICK-REFERENCE.md) with common monitoring commands and one-liners
- Comprehensive monitoring documentation covering traffic analysis, security monitoring, and updown.io integration
- IP blocking recommendations and fail2ban integration guidance
- GoAccess and AWStats tool integration examples
- Real-time monitoring commands and performance tracking

### Changed
- Updated main README.md to include Monitoring tools section

## [1.10.0] - 2025-11-28

### Added
- Comprehensive WordPress cron documentation (provision/CRON.md) covering system cron vs WP-Cron
- WordPress Cron section in migration guide explaining the transition from WP-Cron to system cron
- Multisite cron configuration documentation with real examples
- Cron verification commands and log examples from production systems
- Log filtering commands for monitoring specific sites on multi-site servers
- WordPress Cron section in provision/README.md with reference to detailed guide

### Changed
- Updated migration guide Table of Contents to include WordPress Cron section
- Enhanced provision documentation with cron reference and link to CRON.md

## [1.9.1] - 2025-11-27

### Added
- Theme screenshot example demonstrating proper screenshot formatting and dimensions

## [1.9.0] - 2025-11-26

- This update adds a new ImageMagick command to the RESIZE-AND-CONVERSION.md documentation, specifically for resizing screenshots to fit theme requirements (1200x900 pixels). The command ensures the screenshot is centered and cropped to the exact dimensions, which is useful for maintaining consistency in theme-related visuals.


### Added
- Automated page creation script (page-creation.sh) for deploying WordPress pages to production
- Example WordPress page content file (example-page-content.html) with Gutenberg block markup
- Script features: automated SCP file transfer, conflict detection/resolution, interactive prompts, verification, and cleanup
- Comprehensive automated script documentation section in PAGE-CREATION.md
- Quick Start section in content-creation README with script usage examples
- Files in This Directory section in content-creation README

### Changed
- Updated PAGE-CREATION.md to feature automated script as recommended Option 1 for production deployment
- Enhanced PAGE-CREATION.md with detailed script workflow, customization, security considerations, and requirements
- Reorganized PAGE-CREATION.md Table of Contents to include Automated Script Details and Examples sections
- Removed all references to external `seo-strategy` directory for self-contained documentation
- Updated all code examples to use generic paths and the included example-page-content.html file
- Enhanced content-creation README with script and example file references

## [1.8.0] - 2025-11-25

### Added
- Comprehensive WordPress page creation guide (PAGE-CREATION.md) with step-by-step instructions for Trellis/Bedrock
- Local development workflow using Trellis VM and WP-CLI for page creation
- Production deployment strategies (recreate, export/import, WXR)
- Content preparation guidelines for Gutenberg blocks and patterns
- Common issues and solutions for page creation workflows
- Best practices for development, security, performance, and SEO optimization
- Complete example workflows with full command sequences
- Quick reference guide with essential paths and commands

### Changed
- Enhanced content-creation README with Page Creation Guide reference
- Updated Related Guides section in content-creation README
- Added troubleshooting and additional resources sections to content-creation README

## [1.7.0] - 2025-11-25

### Added
- Out of Memory (OOM) troubleshooting guide with comprehensive WP-Cron memory leak diagnosis
- Mail configuration troubleshooting guide for SMTP issues after Trellis upgrades
- OOM guide includes PHP CLI memory limit analysis, WP-Cron investigation, and Action Scheduler debugging
- Mail guide includes symptoms, diagnosis steps, and prevention best practices
- Mail configuration verification step in trellis-updater.sh that checks for SMTP settings (Brevo/Sendgrid) after update
- `mail.yml` to rsync exclusion list in both trellis-updater.sh and manual-update.md
- Detailed mail.yml restoration instructions in updater script warnings

### Changed
- Updated troubleshooting README to include OOM and MAIL guides in guides table
- Enhanced trellis-updater.sh with mail.yml preservation and verification
- Enhanced manual-update.md with mail.yml exclusion and preservation notes
- Updated updater rsync comments to include SMTP settings preservation category
- Improved file verification warnings with specific restoration commands for mail.yml

## [1.6.0] - 2025-11-23

### Added
- New troubleshooting section with comprehensive server diagnostics guides
- PHP-FPM troubleshooting guide covering pool exhaustion, memory management, worker configuration, and the low-traffic recycling problem
- MariaDB troubleshooting guide covering startup failures, compression plugin issues, and connection problems
- Quick diagnostic commands reference for system health checks

## [1.5.3] - 2025-11-22

### Added
- Critical file verification step in trellis-updater.sh that checks for `.vault_pass`, `ansible.cfg`, and vault.yml files after update
- Vault password troubleshooting section in updater README with step-by-step recovery instructions
- `ansible.cfg` to rsync exclusion list to preserve vault_password_file setting

### Changed
- Updated preservation list in README to note `ansible.cfg` as CRITICAL for vault operations

## [1.5.2] - 2025-11-22

### Added
- Post-upgrade manual review section in updater README with guidance for role templates, new variables, and Galaxy roles
- Organized preservation list by category (Secrets, Git/CI, Site Config, PHP/Server Settings, Deploy Hooks)

### Changed
- Updated trellis-updater.sh to exclude custom PHP/server settings (`main.yml` files) and deploy hooks
- Updated manual-update.md rsync command with additional exclusions for `main.yml` files and `deploy-hooks/`
- Added explanatory comments in updater script for rsync exclude categories

## [1.5.1] - 2025-11-15

### Added
- CLAUDE.md file with comprehensive guidance for Claude Code AI assistant
- Architecture documentation for Ansible playbook structure and patterns
- File naming conventions and compression strategies documentation
- URL management patterns for database operations
- Development workflow guidance for PR creation and backup testing

### Changed
- Updated README with Content Creation Tools section (tool #6)
- Updated README with GitHub PR Creation Script section (tool #7)
- Renumbered Theme Sync Script to #8 and Provisioning Documentation to #9
- Enhanced Requirements section with tool-specific dependencies
- Improved documentation organization and cross-references

## [1.5.0] - 2025-11-15

### Added
- Content creation guide with WordPress block patterns and WP-CLI commands
- Image resizing and conversion guide (RESIZE-AND-CONVERSION.md) with comprehensive ImageMagick examples
- Detailed workflows for creating optimized avatars and thumbnails
- Batch processing examples for image conversion
- Quality settings recommendations for JPEG, WebP, and AVIF formats
- Responsive image workflow examples
- File size comparison data for different image formats

### Changed
- Enhanced image optimization documentation with better structure and cross-references
- Updated README to reference new image resizing guide
- Improved quality settings guidance across all image formats
- Added ImageMagick installation instructions to main image optimization README

## [1.4.0] - 2025-10-23

### Added
- Theme Rsync script for syncing theme files from Trellis to standalone theme repository
- Multi-site migration guide with strategies for migrating multiple WordPress sites to a single Trellis server
- Complete single-site migration guide: Regular WordPress to Trellis/Bedrock
- PR creation shell script for automated pull request workflows
- PHP upgrade additions to provisioning documentation

### Changed
- Updated migration documentation with comprehensive guides and best practices
- Enhanced main README with theme sync and migration guide references

## [1.3.0] - 2025-10-02

### Added
- Provisioning documentation with common Trellis commands and workflows
- Files backup, pull, and push playbooks for managing uploads
- Comprehensive backup documentation with Ansible playbooks and shell scripts
- Backup retention and compression strategies using tar.gz and sql.gz formats

### Changed
- Updated backup playbooks to follow Trellis conventions
- Enhanced database backup script with better export messages
- Improved backup clarification and organization
- Extended browser caching expiry dates for better performance
- Cleaned up assets configuration

### Fixed
- Database export message formatting
- Backup playbooks compatibility issues

### Removed
- Map directive from Nginx configuration

## [1.2.0] - 2025-05-27

### Added
- Site-wide browser caching configuration for static assets
- Assets expiry configuration for images, CSS, JavaScript, and fonts
- Cache headers for optimal performance

### Changed
- Refactored browser caching implementation for better coverage

### Removed
- Deprecated caching directory structure
- Acorn-specific caching references

## [1.1.0] - 2025-04-27

### Added
- WordPress migration tools and commands documentation
- Migration commands for domain changes, multisite handling, and Bedrock path conversions

## [1.0.0] - 2025-04-26

### Added
- Manual Trellis update documentation with step-by-step instructions
- Alternative to automated updater script

### Changed
- Renamed 'updates' directory to 'updater' for clarity

### Fixed
- Nginx configuration typo

## [1.0.0-beta.4] - 2025-04-26

### Added
- Image optimization configuration supporting WebP and AVIF formats
- Nginx configuration for automatic modern image format serving
- Image optimization documentation

### Changed
- Major restructuring of directory organization
- Updated documentation structure for better clarity
- New directory structure for better tool organization

## [1.0.0-beta.3] - 2025-04-24

### Removed
- Deleted files and directories cleanup

## [1.0.0-beta.2] - 2025-04-24

### Changed
- Updated README exclusion list for updater script

## [1.0.0-beta.1] - 2025-04-24

### Added
- Staging vault exclusion in updater script
- .github directory exclusion from updates

### Changed
- Modified copy command to use standard cp without -a flag

## [1.0.0-alpha.2] - 2025-04-24

### Added
- Script limitations documentation
- Note on commit deactivation option

## [1.0.0-alpha.1] - 2025-04-24

### Added
- Initial project setup
- README documentation
- MIT License
- Trellis updater script for safe Trellis updates
- Automated backup and update workflow
- Git integration for tracking changes
