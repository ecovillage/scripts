#!/bin/bash

# Copyright Felix Wolfsteller 2017

# Licensed under the GPLv3+

# rsync this and last weeks log data from website, import it into piwik
# instance and munch it..
# Reads configuration values from import_siebenlinden.org_piwik.sh.conf

# Exit on errors
set -euo pipefail

typeset -A config
get_config_values() {
  # Init array with default values
  config=(
      [remote_log_address]="user@host"
      [local_log_location]="/path/to/logs/"
      [piwik_address]="https://piwik.domain"
      [piwik_idsite]="7"
  )

  # Read /etc/7linden/cp-login.conf
  while read line
  do
      if echo $line | grep -F = &>/dev/null
      then
          varname=$(echo "$line" | cut -d '=' -f 1)
          config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
      fi
  done < import_siebenlinden.org_piwik.sh.conf
  TARGET_DIR="${config[local_log_location]}"/`date +%Y`
  LOG_SOURCE="${config[remote_log_address]}"
}

ensure_target_dir() {
  echo "Ensuring $TARGET_DIR"
  mkdir -p $TARGET_DIR
}

sync_logs() {
  echo "Sync files from $LOG_SOURCE to $TARGET_DIR"
  rsync -avz "$LOG_SOURCE" "$TARGET_DIR"
}

import_logs() {
  YESTERDAY_LOG="$TARGET_DIR"/$(date --date=yesterday +access.log.\%W.\%u.gz)
  echo "Importing $YESTERDAY_LOG"
  sudo -u www-data python /var/www/piwik/misc/log-analytics/import_logs.py \
    --url ${config[piwik_address]}  \
    --log-format-regex='(?P<ip>\S+)\s+\S+\s+(?P<userid>\S+)\s+\[(?P<date>.*?)\s+(?P<timezone>.*?)\]\s+"\S+\s+(?P<path>.*?)\s+\S+"\s+(?P<status>\S+)\s+(?P<length>\S+)\s+(?P<host>[\w\-\.]*)\s+"(?P<referrer>.*?)"\s+"(?P<user_agent>.*?)"' \
    --idsite=${config[piwik_idsite]} \
    $YESTERDAY_LOG > $YESTERDAY_LOG-import.log
  cd /var/www/piwik/ && sudo -u www-data ./console core:archive \
    --force-idsites=${config[piwik_idsite]} \
    --force-all-periods=315576000 \
    --force-date-last-n=1000 \
    --url=${config[piwik_address]}
}


main() {
  get_config_values
  ensure_target_dir
  sync_logs
  import_logs
}

main

exit 0
