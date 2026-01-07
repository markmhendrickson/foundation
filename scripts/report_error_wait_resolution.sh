#!/bin/bash
# wait_for_resolution.sh
# Usage: wait_for_resolution.sh <target-repo-path> <base-filename> [timeout] [poll-interval]

TARGET_REPO="$1"
BASE_FILENAME="$2"
TIMEOUT="${3:-300}"
POLL_INTERVAL="${4:-5}"

ERROR_REPORTS_DIR="$TARGET_REPO/.cursor/error_reports"
PENDING_DIR="$ERROR_REPORTS_DIR/pending"
RESOLVED_DIR="$ERROR_REPORTS_DIR/resolved"

START_TIME=$(date +%s)

while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))
  
  # Check timeout
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "⏱️  Timeout reached (${TIMEOUT}s) while waiting for resolution"
    # Check final status in either directory
    if [ -f "$RESOLVED_DIR/$BASE_FILENAME" ]; then
      STATUS=$(cat "$RESOLVED_DIR/$BASE_FILENAME" | jq -r '.resolution_status' || echo "unknown")
    elif [ -f "$PENDING_DIR/$BASE_FILENAME" ]; then
      STATUS=$(cat "$PENDING_DIR/$BASE_FILENAME" | jq -r '.resolution_status' || echo "unknown")
    else
      STATUS="unknown"
    fi
    echo "Final status: $STATUS"
    exit 0
  fi
  
  # Check both pending/ and resolved/ directories
  REPORT_PATH=""
  if [ -f "$PENDING_DIR/$BASE_FILENAME" ]; then
    REPORT_PATH="$PENDING_DIR/$BASE_FILENAME"
  elif [ -f "$RESOLVED_DIR/$BASE_FILENAME" ]; then
    REPORT_PATH="$RESOLVED_DIR/$BASE_FILENAME"
  else
    echo "⚠️  Error report file not found in pending/ or resolved/: $BASE_FILENAME"
    exit 1
  fi
  
  # Read status
  STATUS=$(cat "$REPORT_PATH" | jq -r '.resolution_status' 2>/dev/null || echo "pending")
  ERROR_ID=$(cat "$REPORT_PATH" | jq -r '.error_id' 2>/dev/null || echo "unknown")
  echo "[WAIT] Error $ERROR_ID status: $STATUS (elapsed: ${ELAPSED}s)"
  
  # Check if resolved or failed
  if [ "$STATUS" = "resolved" ]; then
    echo "✅ Error resolved!"
    cat "$REPORT_PATH" | jq -r '.resolution_notes // "No resolution notes provided."'
    exit 0
  fi
  
  if [ "$STATUS" = "failed" ]; then
    echo "❌ Error resolution failed"
    cat "$REPORT_PATH" | jq -r '.resolution_notes // "No failure reason provided."'
    exit 1
  fi
  
  # Still pending or in_progress, wait and check again
  sleep $POLL_INTERVAL
done


