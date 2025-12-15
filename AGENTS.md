# Repository Guidelines

## Project Structure & Module Organization
- Root contains tool-specific folders: `backup`, `browser-caching`, `content-creation`, `migration`, `monitoring`, `provision`, `redirects`, `image-optimization`, `troubleshooting`, and `updater`, each with its own `README.md` and scripts/playbooks.
- Top-level helpers: `CREATE-PR.md` and `create-pr.sh` (PR helper), `rsync-theme.sh` (theme sync), `LICENSE.md`, `CHANGELOG.md`.
- Keep new tools self-contained: add a folder with a concise `README.md`, scripts under `scripts/` if multiple files, and example configs.

## Build, Test, and Development Commands
- Run updater: `bash updater/trellis-updater.sh` (clone latest Trellis, diff, rsync updates); use a throwaway project dir before touching production.
- Run PR helper: `bash create-pr.sh` (generates PR text via configured AI backends).
- Most guides describe ad-hoc commands (e.g., `ansible-playbook`, `wp`, `rsync`); mirror the documented invocations inside each tool’s `README.md` when adding or updating steps.

## Coding Style & Naming Conventions
- Scripts: Bash with `#!/bin/bash`; prefer `set -euo pipefail`, double-quoting, and long-form flags. Indent with two spaces for readability.
- Variables: UPPER_SNAKE for constants/paths, lower_snake for locals; keep function names verb-based (`run_backup`, `sync_theme`).
- Documentation: Markdown headings, lists, and fenced examples with accurate paths. Keep sections short and actionable.

## Testing Guidelines
- No automated test suite; validate changes by running the exact commands you document with safe flags first (`--check`, `--diff`, `--dry-run` where available).
- For shell changes, sanity-check with `bash -n script.sh`; use `shellcheck` locally if available before submitting.
- Describe manual verification steps in the relevant `README.md` (inputs, expected outputs, cleanup).

## Commit & Pull Request Guidelines
- Commits should be concise, imperative summaries (e.g., `Add monitoring tail script`, `Update backup docs`). Group related changes by tool.
- PRs: include a short description of scope, commands run/outputs (or screenshots for doc-only visual changes), and linked issues if applicable. Note any risk areas (data migration, remote writes).
- Update changelog entries when behavior changes materially; keep doc updates alongside the tool they describe.

## Security & Configuration Tips
- Never commit secrets (vault files, SMTP creds, `.env`, private keys). Use redacted examples and `.example` templates.
- Be cautious with destructive commands (`rm`, `rsync --delete`, database exports); default to dry runs and document required backups/restores.
