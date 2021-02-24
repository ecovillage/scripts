#!/bin/bash

# Copyright Felix Wolfsteller 2021

# Licensed under the GPLv3+

# Initialize a borg repo.
# Configuration in .conf

# Exit on errors
set -euo pipefail

script_path="$(basename $0)"

typeset -A config
get_config_values() {
  # Init array with default values
  config=(
      [repo]="user@host"
      [ssh_key_path]="/path/to/key/"
      [passphrase]="yourphrase"
      [quota]="100G"
  )

  # Read from this script filename + .conf at the end
  while read line
  do
      if echo $line | grep -F = &>/dev/null
      then
          varname=$(echo "$line" | cut -d '=' -f 1)
          config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
      fi
  done < "$script_path.conf"
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

