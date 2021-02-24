#!/bin/bash

# Copyright Felix Wolfsteller 2021

# Licensed under the GPLv3+

# Create a borg archive and prune.
# Strongly inspired from from https://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups
# Configuration in .conf

# Exit on errors
set -euo pipefail

trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

script_path="$(basename $0)"

typeset -A config
get_config_values() {
  # Init array with default values
  config=(
      [repo]="user@host"
      [ssh_key_path]="/path/to/key/"
      [passphrase]="yourphrase"
      [quota]="100G"
      [keep_daily]="3"
      [keep_weekly]="3"
      [keep_monthly]="3"
      [keep_yearly]="3"
      [source_dir]="/path/to/source/dir"
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

info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }

create_archive() {
  export BORG_RSH="ssh -i ${config[ssh_key_path]}"
  export BORG_REPO="${config[repo]}"
  export BORG_PASSPHRASE="${config[passphrase]}"

  info "Starting backup"
  borg create                         \
      --verbose                       \
      --filter AME                    \
      --list                          \
      --stats                         \
      --show-rc                       \
      --compression lz4               \
      --exclude-caches                \
                                      \
      ::'{now}'                       \
                                      \
      "${config[source_dir]}" 
  
  backup_exit=$?
}

prune_repo() {
  info "Pruning repository"

  borg prune                                  \
      --list                                  \
      --show-rc                               \
      --keep-daily   "${config[keep_daily]}"  \
      --keep-weekly  "${config[keep_weekly]}" \
      --keep-monthly "${config[keep_daily]}"  \
      --keep-yearly  "${config[keep_yearly]}" \
  
  prune_exit=$?
}

main() {
  get_config_values
  create_archive
  prune_repo
}

main

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}

# Magicians come here
exit 0

