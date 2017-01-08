#!/bin/sh
#
# Version 0.3.1
#
# This script catches all appearences of $searchstr.
# grep command displays $window lines above $searchstr.
# The grep output is piped via tac to next grep command
# which gets for the appearance of $regstr.
# Output should be the user data of failed registrations

# search string for webserver error
searchstr="ECONNREFUSED"
# search string for backward search
regstr='INSERT INTO `registrations`'
# amount of lines for backward search
window=5

# Exit with errormessage and exit code.
errmsg_exit (){
  echo "$1"
  echo "Nothing to do, exiting."
  exit "$2"
}

if [ $# -eq 0 ]; then
  errmsg_exit "Usage: $(basename "$0") logfile" "1"
else
  if ! [ -e $1 ]; then
    errmsg_exit "$(basename "$0"): "$1" doesn't exist." "2"
  fi
fi

# display $window lines above each hit of $searchstr
grep -n -B $window "$searchstr" "$1" | \
# now search backwards to get last appearance of $regstr
tac | grep "$regstr" | tac | \
# cut out VALUES field of JSON string | delete quotes and braces | delete trailing ')'
awk -F 'VALUES \(' '{ print $2 }' | tr -d "\'\[\]" | awk -F '\)$' '{print $1}' | \
# printf fields seperated by ','. Print 'date'-field first
awk -F ',' '{ printf $NF" "; for(i=1; i<NF; i++ ){ printf $i }; printf "\n"}' | \
# cut leading :blank: and look for double lines skipping leading 'date'-field
sed 's/^[ \t]*//' | uniq -f 2


exit 0
