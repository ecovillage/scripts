#!/bin/bash

# Copyright Felix Wolfsteller 2017

# Licensed under the GPLv3+

# Consumes a apache-style access.log file (deletes it) and imports to idsite1,
# recalculating indexes.

# Exit on errors
set -euo pipefail

if [ $# -ne 1 ]
then
  echo "Need to specify arguments (path to access.log file)!"
  exit 1
fi

ACCESS_LOG_FILE=$(realpath "$1")

sudo chown www-data "$ACCESS_LOG_FILE"

sudo -u www-data python /var/www/piwik/misc/log-analytics/import_logs.py --url http://192.168.1.166/piwik --idsite=1 $ACCESS_LOG_FILE
cd /var/www/piwik/ && sudo -u www-data ./console core:archive --force-idsites=1 --force-all-periods=315576000 --force-date-last-n=1000 --url='http://192.168.1.166/piwik'
sudo rm $ACCESS_LOG_FILE

exit 0
