#!/bin/bash

# Copyright Felix Wolfsteller 2021

# Licensed under the GPLv3+

# Yet another borg wrapper
# Configuration in .conf

# Exit on errors
set -euo pipefail

trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

script_path="$(basename $0)"
script_args="$@"

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

export_env() {
  export BORG_RSH="ssh -i ${config[ssh_key_path]}"
  export BORG_REPO="${config[repo]}"
  export BORG_PASSPHRASE="${config[passphrase]}"
}

main() {
  get_config_values
  export_env

  borg $script_args
}

main

exit 0

