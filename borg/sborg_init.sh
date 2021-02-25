#!/bin/bash

# Copyright Felix Wolfsteller 2021

# Licensed under the GPLv3+

# Initialize a borg repo.
# ./sborg_init.sh conf-file.conf

# Exit on errors
set -euo pipefail

if [ -z "$1" ]
then
  echo "Specify configuration file as argument"
  exit 1
fi

conf_file="$1"

typeset -A config
get_config_values() {
  # Init array with default values
  config=(
      [repo]="user@host"
      [ssh_key_path]="/path/to/key/"
      [passphrase]="yourphrase"
      [quota]="100G"
  )

  # Read from supplied conf file
  while read line
  do
      if echo $line | grep -F = &>/dev/null
      then
          varname=$(echo "$line" | cut -d '=' -f 1)
          config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
      fi
  done < "$conf_file"
}

init_repo() {
  export BORG_RSH="ssh -i ${config[ssh_key_path]}"
  export BORG_REPO="${config[repo]}"
  export BORG_PASSPHRASE="${config[passphrase]}"

  echo "Initialising the repo"
  borg init --encryption=repokey
}

main() {
  get_config_values
  init_repo
}

main

exit 0

