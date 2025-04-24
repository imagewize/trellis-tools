#!/bin/bash

# Set your project slug here like imagewize.com
PROJECT="site.com"

# Paths based on project
PROJECT_DIR=~/code/$PROJECT
TRELLIS_DIR=$PROJECT_DIR/trellis
BACKUP_DIR=~/trellis-backup
TEMP_DIR=~/trellis-temp
DIFF_DIR=~/trellis-diff

# Step 1: Create backup directory
mkdir -p $BACKUP_DIR

# Step 2: Back up the entire current Trellis directory including hidden files
cp -r $TRELLIS_DIR/ $BACKUP_DIR/

# Step 3: Clone fresh Trellis to temporary directory
mkdir -p $TEMP_DIR
cd $TEMP_DIR
git clone git@github.com:roots/trellis.git

# Step 4: Generate diff to see what would change
mkdir -p $DIFF_DIR
diff -rq $TEMP_DIR/trellis/ $TRELLIS_DIR/ > $DIFF_DIR/changes.txt

# Step 5: Remove .git directory from the cloned Trellis to prevent conflicts
rm -rf $TEMP_DIR/trellis/.git

# Step 6: Update Trellis files using rsync with explicit excludes
rsync -av \
  --exclude=".vault_pass" \
  --exclude=".trellis/" \
  --exclude=".git/" \
  --exclude=".github/" \
  --exclude="group_vars/all/vault.yml" \
  --exclude="group_vars/development/vault.yml" \
  --exclude="group_vars/development/wordpress_sites.yml" \
  --exclude="group_vars/production/vault.yml" \
  --exclude="group_vars/production/wordpress_sites.yml" \
  --exclude="group_vars/staging/vault.yml" \
  --exclude="group_vars/staging/wordpress_sites.yml" \
  --exclude="group_vars/all/users.yml" \
  --exclude="trellis.cli.yml" \
  --exclude="hosts/" \
  $TEMP_DIR/trellis/ $TRELLIS_DIR/

# Step 7: Clean up temporary directory
# rm -rf $TEMP_DIR

# Step 8: Return to project directory
# cd $PROJECT_DIR

# Step 9: Check status of changes
# git status

# Step 10: Review diff of changes
# git diff trellis/

# Step 11: Add changes if everything looks good
# git add trellis/

# Step 12: Commit the changes
# git commit -m "Update Trellis to latest version while preserving custom configurations"
