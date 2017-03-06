#!/bin/bash

# Copyright Felix Wolfsteller 2017

# Exit on errors
set -euo pipefail

if [ $# -ne 1 ]
then
  echo "Need to specify arguments (path to wp_config.php)!"
  exit 1
fi

WP_CONF="$1"

conf_value() {
  declare key="$1"
  grep "$key" "$WP_CONF" | grep -o " '.*')" | grep -o "'.*'" | grep -o "[^\']*"
}

DBNAME=$(conf_value "DB_NAME")
DBUSER=$(conf_value "DB_USER")
DBPASS=$(conf_value "DB_PASSWORD")
DBHOST=$(conf_value "DB_HOST")

mysqldump --compatible=mysql4 --add-drop-table -h $DBHOST -u $DBUSER -p"$DBPASS" $DBNAME > wordpress.`date +%F`.sql
