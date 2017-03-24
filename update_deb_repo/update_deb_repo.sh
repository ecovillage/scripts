#!/bin/bash

# Copyright 2017 Felix Wolfsteller
# Licensed under the GPLv3+

# No time for explanation, see internal wiki.

# Bail out on errors
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'
CLEAR_LINE='\r\033[K' # (use with printf)

typeset -A config

# Get config values from build_7l_debs.conf if it exists.
get_config_values() {
  # Init array with default values
  config=(
      [package_repos_path]="."
      [deb_target_path]="."
      [host]="user@localhost:/srv/deb"
      [sign_key]="4E78E11"
  )

  # Read build_7l_debs.conf if it exists
  [ -f build_7l_debs.conf ] && while read line
  do
      if echo $line | grep -F = &>/dev/null
      then
          varname=$(echo "$line" | cut -d '=' -f 1)
          config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
      fi
  done < build_7l_debs.conf
}

build_debs() {
  for repo in `ls "${config[package_repos_path]}"`; do
    cd "${config[package_repos_path]}"
    cd "$repo"
    pwd
    # this is dodgy, still does not work in all circumstances
    git pull origin master --quiet
    #git pull --quiet
    LAST_TAG=`git describe --tags $(git rev-list --tags --max-count=1)`
    echo "Building $repo" at: "$LAST_TAG"
    git checkout "$LAST_TAG" --quiet
    ./create.sh > /dev/null
    mv *.deb "${config[deb_target_path]}/all/"
    printf "${GREEN}Built $repo ($LAST_TAG)${NO_COLOR}"
    echo
  done
}

build_repo() {
  cd ${config[deb_target_path]}

  # Create Packages / .gz
  apt-ftparchive packages . > Packages
  gzip -9c Packages > Packages.gz

  # Create Release / .gpg
  apt-ftparchive release . > Release
  # TODO key as config var
  gpg -abs -u ${config[sign_key]} -o Release.gpg Release
}

push_to_repo() {
  # only debs, not debs/all
  echo "scp -r ${config[deb_target_path]} ${config[host]}"
  scp -r ${config[deb_target_path]} ${config[host]}
}

main() {
  printf "$0: Reading configuration from ./build_7l_debs.conf"
  echo
  get_config_values

  echo "Searching package repositories in ${config[package_repos_path]}"
  build_debs

  echo "Entering ${config[deb_target_path]} to sign and push release"
  build_repo

  echo "Pushing to repo"
  push_to_repo
}

main

exit 0
