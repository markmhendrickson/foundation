#!/bin/bash
# generate_error_id.sh
# Outputs: ERROR_ID|TIMESTAMP

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%S")
ERROR_ID="01JQ$(echo $TIMESTAMP | tr -d 'T' | cut -c1-20)"
echo "${ERROR_ID}|${TIMESTAMP}"


