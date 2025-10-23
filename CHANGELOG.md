# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/imagewize/trellis-tools/compare/v1.3.0...HEAD
[1.4.0]: https://github.com/imagewize/trellis-tools/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/imagewize/trellis-tools/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/imagewize/trellis-tools/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/imagewize/trellis-tools/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/imagewize/trellis-tools/compare/v1.0.0-beta.4...v1.0.0
[1.0.0-beta.4]: https://github.com/imagewize/trellis-tools/compare/v1.0.0-beta.3...v1.0.0-beta.4
[1.0.0-beta.3]: https://github.com/imagewize/trellis-tools/compare/v1.0.0-beta.2...v1.0.0-beta.3
[1.0.0-beta.2]: https://github.com/imagewize/trellis-tools/compare/v1.0.0-beta.1...v1.0.0-beta.2
[1.0.0-beta.1]: https://github.com/imagewize/trellis-tools/compare/v1.0.0-alpha.2...v1.0.0-beta.1
[1.0.0-alpha.2]: https://github.com/imagewize/trellis-tools/compare/v1.0.0-alpha.1...v1.0.0-alpha.2
[1.0.0-alpha.1]: https://github.com/imagewize/trellis-tools/releases/tag/v1.0.0-alpha.1
