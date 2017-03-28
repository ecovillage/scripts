#!/bin/bash

# Copyright Felix Wolfsteller 2017
# Call in the directory that should contain the stage.

# Exit on errors
set -euo pipefail

if [ $# -ne 3 ]
then
  echo "Need to specify arguments (NAME MYSQLDUMPFILE MYSQLPWD PASSWORD)!"
  exit 1
fi

MYSQLDUMP="$1"
MYSQLPWD="$3"

THE_RAND=$(openssl rand -base64 6)
DBNAME="wordpress-$THE_RAND"
DBUSER="wordpress-$THE_RAND"
DBPASS="$THE_RAND"

#mysql -u root --password=$MYSQLPWD << END
cat << END

CREATE DATABASE $DBNAME;
GRANT ALL PRIVILEGES ON $DBNAME.* TO \"$DBUSER\"@\"localhost\" IDENTIFIED BY \"$DBPASS\";
FLUSH PRIVILEGES;
EXIT"

END

echo "Created DB $DBNAME with User $DBUSER (Password: $DBPASS )"

wget --no-check-certificate https://wordpress.org/latest.tar.gz

tar --strip-components=1 -xzvf latest.tar.gz

chown -R www-data:www-data .

cp wp-config-sample.php wp-config.php
sed -ie "s/database_name_here/$DBNAME/" wp-config.php
sed -ie "s/username_here/$DBUSER/" wp-config.php
sed -ie "s/password_here/$DBPASS/" wp-config.php

#mysql -h mysqlhostserver -u mysqlusername -p databasename < blog.bak.sql
