#!/bin/bash
# validate_target_repo.sh
# Usage: validate_target_repo.sh <target-repo-path>

TARGET_REPO="$1"

if [ -z "$TARGET_REPO" ]; then
  echo "❌ Error: Target repository path required"
  exit 1
fi

# Check if path exists
if [ ! -d "$TARGET_REPO" ]; then
  echo "❌ Error: Target repository not found: $TARGET_REPO"
  exit 1
fi

# Check if it's a git repository
if [ ! -d "$TARGET_REPO/.git" ]; then
  echo "❌ Error: Target path is not a git repository: $TARGET_REPO"
  exit 1
fi

# Check write permissions
if [ ! -w "$TARGET_REPO" ]; then
  echo "❌ Error: No write permission for target repository: $TARGET_REPO"
  exit 1
fi

echo "✅ Target repository validated: $TARGET_REPO"
exit 0


