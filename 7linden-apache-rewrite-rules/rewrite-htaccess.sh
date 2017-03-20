#!/bin/bash

# Copyright 2017, Holger Nassenstein.
# Released under the [GPLv3](LICENSE) included as LICENSE file.

# Input
# Read from file given as argument.
# That file can include comments, which are lines starting with '#'.
# Each other line follows the pattern OLD_URL NEW_URL (separated by a space).
# Output
# A file that can be used as .htaccess for Apaches with mod_rewrite to
# define redirection patterns from OLD_URLs to NEW_URLs.

# Exit on errors
set -eu
# set -o pipefail exits script immediately after first call of rewrite_rules ()

SOURCE="http://www.siebenlinden.de"
DEST="http://draft.siebenlinden.org"
FIFO="/tmp/$(basename $0)$$"
# 302: temporary ; 301: permament
REDIRECT_STATUS_CODE="302"

if [ $# -ne 1 ]
then
  echo "$0 <FILE>: Argument needed"
  echo "Need to specify one argument (path to file with space separated old/new urls)!"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "$1 does not exist. $0 finishing:"
  exit 1
fi

mkfifo "$FIFO"

cat <<EOF
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^$ $DEST/? [R=$REDIRECT_STATUS_CODE,L,R]
Redirect $REDIRECT_STATUS_CODE index\.php $DEST/
EOF

rewrite_rules () {
  # map out comment and empty lines:
  grep -v "^$" "$FIFO" | grep -v "^#" |\
  # grep for lines beginning with "http://www.siebenlinden.de/"
  grep "^$SOURCE/" |\
  # end of line must be a question mark:
  sed "s/$/?/"|\
  # replace http://www.siebenlinden.de/ by new line RewriteCond ...
  sed "s|^$SOURCE/index.php|RewriteCond %{REQUEST_URI} ^\\\/index\\\.php$\n|" |\
  # replace ?id= by new line /RewriteCond %{QUERY_STRING}:
  eval $1 |\
#  sed "s/?id=\([0-9]*\).* /RewriteCond %{QUERY_STRING} ^id=\1(\&L=.*)*$\nRewriteRule .* /" |\
  # sed "s/?id=\(.*\)           # with language parameter
  # sed -e 's/?id=\([0-9]*\).*  # without language parameter
  sed "s/?$/? [R=$REDIRECT_STATUS_CODE,L,R]/"
}

# grep for english-speaking pages:
grep "&L=2 " "$1" > "$FIFO" &
rewrite_rules 'sed "s/?id=\(.*\) /RewriteCond %{QUERY_STRING} ^id=\1$\nRewriteRule \.\* /"'
# grep for french-speaking pages:
grep "&L=3 " "$1" > "$FIFO" &
rewrite_rules 'sed "s/?id=\(.*\) /RewriteCond %{QUERY_STRING} ^id=\1$\nRewriteRule \.\* /"'
# now map out english- and french-speaking pages:
grep -v "&L=2 " "$1" | grep  -v "&L=3 " > "$FIFO" &
rewrite_rules 'sed "s/?id=\([0-9]|[a-z]*\).* /RewriteCond %{QUERY_STRING} ^id=\1(\&L=.*)*$\nRewriteRule \.\* /"'

cat << EOF
RewriteCond %{QUERY_STRING} ^.(.*)$
RewriteRule ^index\.php$ $DEST/? [R=$REDIRECT_STATUS_CODE,L,R]
RewriteRule ^index\.php$ - [L]
RewriteRule . /index.php [L]
</IfModule>
EOF

rm "$FIFO"

exit 0
