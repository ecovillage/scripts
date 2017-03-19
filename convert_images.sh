#!/bin/bash

# Copyright Felix Wolfsteller 2017

# Convert all images in current directory to a max width or height of 1024px,
# jpeg format, quality parameter of 85.
# Fails directly if an image cant be converted (or isnt an image).
# Minimal effort to sane filenames done.

# Exit on errors
set -euo pipefail

for file in *;
do
  file_ext=${file##*.}
  fname=$(basename "$file" "$file_ext")
  # We could also restrict set of valid chars to alnum.
  new_name="nl_$(echo $fname | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g')jpg"
  convert -resize "1024x1024>" -quality 85 "$file" "$new_name"
done

