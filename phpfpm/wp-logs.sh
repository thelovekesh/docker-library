#!/bin/bash

set -e

if [[ -z "$LANDO_MOUNT" ]]; then
  echo "Error: Must be run from within a Lando environment."
  exit 1
fi

# This path must be set as WP_DEBUG_LOG in wp-config.php
ERROR_LOG_PATH="/tmp/php-error.log"

if [[ ! -e "$ERROR_LOG_PATH" ]]; then
  touch "$ERROR_LOG_PATH"
  echo "Make sure to set WP_DEBUG_LOG in wp-config.php to $ERROR_LOG_PATH"
fi

tail -f "$ERROR_LOG_PATH"
