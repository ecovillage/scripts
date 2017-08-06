#!/bin/bash

# Copyright Felix Wolfsteller 2017

# Licensed under the GPLv3+

# Iterate over all users and display their crontab.

# Exit on certain errors
set -uo pipefail

main() {
  for user in $(cut -f1 -d: /etc/passwd); do
    echo $user
    crontab -u $user -l \
      | grep -v '^#.*'
    echo
  done
}

main

exit 0
