#!/bin/bash

# WordPress Theme Release Script with Claude AI Integration
# Automates version bumping and changelog updates for theme releases
# Supports both demo/ and site/ Bedrock installations
#
# Usage:
#   ./release-theme.sh <theme-name> <version> [--commit]
#   ./release-theme.sh elayne 1.2.5          # Demo site theme
#   ./release-theme.sh nynaeve 1.0.0 --commit # Main site theme
#
# What it does:
# 1. Compares current branch to main branch
# 2. Uses Claude CLI to analyze changes and generate changelog
# 3. Updates version in style.css, readme.txt, and CHANGELOG.md
# 4. Creates professional changelog entries in both formats
# 5. Shows git diff for review
# 6. Optionally commits changes with standardized message
#
# Requirements:
# - claude CLI installed and authenticated
# - git repository with main branch

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check requirements
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude CLI is required but not installed${NC}"
    echo "Install with: npm install -g @anthropic-ai/claude-cli"
    echo "Or see: https://github.com/anthropics/claude-cli"
    exit 1
fi

# Check if theme name argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Theme name and version required${NC}"
    echo "Usage: $0 <theme-name> <version> [--commit]"
    echo "Example: $0 elayne 1.2.5"
    echo "Example: $0 moiraine 2.1.0 --commit"
    exit 1
fi

# Check if version argument is provided
if [ -z "$2" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: $0 <theme-name> <version> [--commit]"
    echo "Example: $0 elayne 1.2.5"
    exit 1
fi

THEME_NAME="$1"
NEW_VERSION="$2"

# Determine theme directory based on theme name
# Check both demo/ and site/ Bedrock installations
if [ -d "demo/web/app/themes/$THEME_NAME" ]; then
    THEME_DIR="demo/web/app/themes/$THEME_NAME"
    BEDROCK_TYPE="demo"
elif [ -d "site/web/app/themes/$THEME_NAME" ]; then
    THEME_DIR="site/web/app/themes/$THEME_NAME"
    BEDROCK_TYPE="site"
else
    echo -e "${RED}Error: Theme '$THEME_NAME' not found in demo/ or site/ installations${NC}"
    echo ""
    echo "Available themes in demo/:"
    if [ -d "demo/web/app/themes/" ]; then
        ls -1 demo/web/app/themes/ | grep -v "^index.php$" | sed 's/^/  - /'
    else
        echo "  (demo/web/app/themes/ not found)"
    fi
    echo ""
    echo "Available themes in site/:"
    if [ -d "site/web/app/themes/" ]; then
        ls -1 site/web/app/themes/ | grep -v "^index.php$" | sed 's/^/  - /'
    else
        echo "  (site/web/app/themes/ not found)"
    fi
    exit 1
fi

# Validate version format (semantic versioning: X.Y.Z)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo "Version must be in format X.Y.Z (e.g., 1.2.5)"
    exit 1
fi

THEME_DISPLAY_NAME=$(echo "$THEME_NAME" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
echo -e "${BLUE}=== $THEME_DISPLAY_NAME Theme Release Tool with Claude AI ===${NC}"
echo ""

# Get current version from style.css
CURRENT_VERSION=$(grep "^Version:" "$THEME_DIR/style.css" | sed 's/Version: //')
echo -e "Theme location:  ${BLUE}$BEDROCK_TYPE/web/app/themes/$THEME_NAME${NC}"
echo -e "Current version: ${YELLOW}$CURRENT_VERSION${NC}"
echo -e "New version:     ${GREEN}$NEW_VERSION${NC}"
echo ""

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Current branch:  ${BLUE}$CURRENT_BRANCH${NC}"
echo ""

# Confirm before proceeding
read -p "Continue with release? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Release cancelled."
    exit 0
fi

echo -e "${BLUE}Step 1: Analyzing changes from main branch...${NC}"

# Get git diff between current branch and main
GIT_DIFF=$(git diff main..HEAD -- "$THEME_DIR" | head -c 50000)  # Limit to ~50KB

if [ -z "$GIT_DIFF" ]; then
    echo -e "${YELLOW}  ⚠ Warning: No changes detected between main and $CURRENT_BRANCH${NC}"
    echo "  Are you on the correct branch?"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Release cancelled."
        exit 0
    fi
fi

echo "  ✓ Retrieved changes from git diff"

echo -e "${BLUE}Step 2: Using Claude AI to generate changelog...${NC}"

# Create prompt for Claude CLI
CLAUDE_PROMPT="You are analyzing changes for the $THEME_DISPLAY_NAME WordPress theme release version $NEW_VERSION (previous version: $CURRENT_VERSION).

Based on the git diff below, generate TWO changelog formats:

1. **CHANGELOG.md format** (detailed, Keep a Changelog style):
   - Use headers: ### Changed, ### Added, ### Fixed, ### Technical
   - Include sub-sections with **bold titles** and bullet points
   - Be detailed and descriptive
   - Example:
     ### Changed - Navigation improvements
     **Navigation Chevron Spacing:**
     - Reduced gap between parent menu text and chevron from 0.5rem to 0.25rem
     - Tighter, more compact visual appearance

2. **readme.txt format** (concise, WordPress.org style):
   - Single-line entries with prefixes: CHANGED, ADDED, FIXED, TECHNICAL
   - Condensed and abbreviated
   - Example:
     * CHANGED: Navigation chevron spacing - Reduced gap from 0.5rem to 0.25rem for tighter appearance.

Git diff:
\`\`\`
$GIT_DIFF
\`\`\`

Return ONLY valid JSON in this exact format (no markdown code blocks):
{
  \"changelog_md\": \"### Changed\\n...\",
  \"readme_txt\": \"* CHANGED: ...\"
}

Be concise but informative. Focus on user-visible changes."

# Call Claude CLI
CLAUDE_RESPONSE=$(echo "$CLAUDE_PROMPT" | claude --print 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}  ✗ Claude CLI call failed${NC}"
    echo "Error: $CLAUDE_RESPONSE"
    exit 1
fi

# Parse JSON from Claude's response
# Claude may wrap JSON in markdown code blocks, so extract it
CHANGELOG_JSON=$(echo "$CLAUDE_RESPONSE" | sed -n '/^{/,/^}/p')

if [ -z "$CHANGELOG_JSON" ]; then
    echo -e "${RED}  ✗ Failed to parse Claude's response${NC}"
    echo "Claude returned: $CLAUDE_RESPONSE"
    exit 1
fi

# Extract changelog entries using simple text processing (no jq needed)
CHANGELOG_MD=$(echo "$CHANGELOG_JSON" | grep -o '"changelog_md"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"changelog_md"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/' | sed 's/\\n/\n/g')
README_TXT=$(echo "$CHANGELOG_JSON" | grep -o '"readme_txt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"readme_txt"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/' | sed 's/\\n/\n/g')

if [ -z "$CHANGELOG_MD" ] || [ -z "$README_TXT" ]; then
    echo -e "${RED}  ✗ Failed to extract changelog entries${NC}"
    echo "JSON: $CHANGELOG_JSON"
    exit 1
fi

echo "  ✓ Generated changelog with Claude AI"

# Date formats
CHANGELOG_DATE=$(date +%Y-%m-%d)  # 2025-12-31
README_DATE=$(date +%m/%d/%y)    # 12/31/25

echo -e "${BLUE}Step 3: Updating version numbers...${NC}"

# Update style.css
sed -i.bak "s/^Version: .*/Version: $NEW_VERSION/" "$THEME_DIR/style.css"
echo "  ✓ Updated style.css"

# Update readme.txt stable tag
sed -i.bak "s/^Stable tag: .*/Stable tag: $NEW_VERSION/" "$THEME_DIR/readme.txt"
echo "  ✓ Updated readme.txt"

# Remove backup files
rm -f "$THEME_DIR/style.css.bak" "$THEME_DIR/readme.txt.bak"

echo -e "${BLUE}Step 4: Updating CHANGELOG.md...${NC}"

# Create temporary file with changelog content
TEMP_CHANGELOG=$(mktemp)
echo -e "$CHANGELOG_MD" > "$TEMP_CHANGELOG"

# Create new release entry in CHANGELOG.md
# First, check if "Unreleased" section exists
if grep -q "^## \[Unreleased\]" "$THEME_DIR/CHANGELOG.md"; then
    # Clear the Unreleased section and add new version
    awk -v version="$NEW_VERSION" -v date="$CHANGELOG_DATE" -v tmpfile="$TEMP_CHANGELOG" '
        /^## \[Unreleased\]/ {
            print $0
            print ""
            print "## [" version "] - " date
            print ""
            while ((getline line < tmpfile) > 0) {
                print line
            }
            close(tmpfile)
            print ""
            skip=1
            next
        }
        /^## \[/ && skip {
            skip=0
        }
        !skip {
            print $0
        }
    ' "$THEME_DIR/CHANGELOG.md" > "$THEME_DIR/CHANGELOG.md.tmp"
    mv "$THEME_DIR/CHANGELOG.md.tmp" "$THEME_DIR/CHANGELOG.md"
else
    # No Unreleased section, just prepend new version after main header
    awk -v version="$NEW_VERSION" -v date="$CHANGELOG_DATE" -v tmpfile="$TEMP_CHANGELOG" '
        /^## \[/ && !done {
            print "## [" version "] - " date
            print ""
            while ((getline line < tmpfile) > 0) {
                print line
            }
            close(tmpfile)
            print ""
            done=1
        }
        { print $0 }
    ' "$THEME_DIR/CHANGELOG.md" > "$THEME_DIR/CHANGELOG.md.tmp"
    mv "$THEME_DIR/CHANGELOG.md.tmp" "$THEME_DIR/CHANGELOG.md"
fi

# Clean up temp file
rm -f "$TEMP_CHANGELOG"

echo "  ✓ Added release entry to CHANGELOG.md"

echo -e "${BLUE}Step 5: Updating readme.txt changelog...${NC}"

# Create temporary file with readme content
TEMP_README=$(mktemp)
echo -e "$README_TXT" > "$TEMP_README"

# Add new changelog entry to readme.txt
# Insert after "== Changelog ==" line
awk -v version="$NEW_VERSION" -v date="$README_DATE" -v tmpfile="$TEMP_README" '
    /^== Changelog ==/ {
        print $0
        print ""
        print "= " version " - " date " ="
        while ((getline line < tmpfile) > 0) {
            print line
        }
        close(tmpfile)
        print ""
        next
    }
    { print $0 }
' "$THEME_DIR/readme.txt" > "$THEME_DIR/readme.txt.tmp"
mv "$THEME_DIR/readme.txt.tmp" "$THEME_DIR/readme.txt"

# Clean up temp file
rm -f "$TEMP_README"

echo "  ✓ Added changelog entry to readme.txt"

echo ""
echo -e "${GREEN}=== Release preparation complete! ===${NC}"
echo ""
echo -e "${BLUE}Generated Changelog Preview:${NC}"
echo ""
echo -e "${YELLOW}CHANGELOG.md:${NC}"
echo "$CHANGELOG_MD" | head -20
echo ""
echo -e "${YELLOW}readme.txt:${NC}"
echo "$README_TXT" | head -10
echo ""
echo -e "${BLUE}Step 6: Review changes...${NC}"
echo ""

# Show git diff
git diff "$THEME_DIR/style.css" "$THEME_DIR/readme.txt" "$THEME_DIR/CHANGELOG.md"

echo ""
echo -e "${YELLOW}=== Next Steps ===${NC}"
echo ""
echo "1. Review the changes above"
echo "2. Manually edit CHANGELOG.md and readme.txt if needed"
echo "3. Commit the changes:"
echo -e "   ${GREEN}git add $THEME_DIR/{style.css,readme.txt,CHANGELOG.md}${NC}"
echo -e "   ${GREEN}git commit -m \"$THEME_DISPLAY_NAME Version $NEW_VERSION\"${NC}"
echo ""
echo "4. Push and create PR:"
echo -e "   ${GREEN}git push origin $CURRENT_BRANCH${NC}"
echo -e "   ${GREEN}./create-pr.sh main \"$THEME_DISPLAY_NAME Version $NEW_VERSION\"${NC}"
echo ""

# Optional auto-commit
if [ "$3" = "--commit" ]; then
    echo -e "${BLUE}Auto-committing changes...${NC}"
    git add "$THEME_DIR/style.css" "$THEME_DIR/readme.txt" "$THEME_DIR/CHANGELOG.md"
    git commit -m "$THEME_DISPLAY_NAME Version $NEW_VERSION"
    echo -e "${GREEN}✓ Changes committed!${NC}"
    echo ""
    echo "Next: Push and create PR with:"
    echo -e "   ${GREEN}git push origin $CURRENT_BRANCH${NC}"
    echo -e "   ${GREEN}./create-pr.sh main \"$THEME_DISPLAY_NAME Version $NEW_VERSION\"${NC}"
fi
