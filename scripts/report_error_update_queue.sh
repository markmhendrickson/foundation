#!/bin/bash
# update_pending_queue.sh
# Usage: update_pending_queue.sh <target-repo-path> <error-id> <timestamp> <category> <severity> <json-path>

TARGET_REPO="$1"
ERROR_ID="$2"
TIMESTAMP="$3"
CATEGORY="$4"
SEVERITY="$5"
JSON_PATH="$6"

PENDING_FILE="$TARGET_REPO/.cursor/error_reports/pending.json"
NEW_ENTRY="{\"error_id\": \"$ERROR_ID\", \"timestamp\": \"$(echo $TIMESTAMP | sed 's/\(....\)\(..\)\(..\)T\(..\)\(..\)\(..\)/\1-\2-\3T\4:\5:\6Z/')\", \"category\": \"$CATEGORY\", \"severity\": \"$SEVERITY\", \"file_path\": \"$JSON_PATH\"}"

if [ -f "$PENDING_FILE" ]; then
  cat "$PENDING_FILE" | jq ". + [$NEW_ENTRY]" > "$PENDING_FILE.tmp" && mv "$PENDING_FILE.tmp" "$PENDING_FILE"
else
  echo "[$NEW_ENTRY]" > "$PENDING_FILE"
fi

echo "✅ Pending queue updated"


