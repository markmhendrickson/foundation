#!/bin/bash
# create_error_report_dirs.sh
# Usage: create_error_report_dirs.sh <target-repo-path>

TARGET_REPO="$1"
ERROR_REPORTS_DIR="$TARGET_REPO/.cursor/error_reports"
PENDING_DIR="$ERROR_REPORTS_DIR/pending"
RESOLVED_DIR="$ERROR_REPORTS_DIR/resolved"

mkdir -p "$PENDING_DIR" "$RESOLVED_DIR"
echo "✅ Created error report directories in $TARGET_REPO"



