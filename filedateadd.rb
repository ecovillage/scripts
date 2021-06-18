#!/usr/bin/env ruby

# Copyright 2021 Felix Wolfsteller
# Released under the GPLv3+

# Inject YYYYMM into file names

require 'pathname'

if ARGV.length == 0 || !File.directory?(ARGV[0])
  STDERR.puts "expecting directory as argument"
  exit 1
end

directory = ARGV[0]
now       = Time.now
$now_s    = now.strftime("%Y%m")

def inject_timestamp(path)
  ext  = path.extname
  name = path.basename(".*")

  path.dirname + (name.to_s + '_' + $now_s + + ext)
end

files = Dir.glob(directory + "/**").map{|f| Pathname.new(f)}.reject{|f| !f.file?}

files.each do |path|
  # already contains timestamp (e.g. something_202105.mp4)
  if path.to_s =~ /_[0-9]{6}\..{3}/
    next
  end

  new_path = inject_timestamp(path)
  # rename can be destructive, this will not prevent against race conditions
  if new_path.exist?
    next
  end

  puts "would rename #{path} to #{new_path}"
  path.rename new_path
end

exit 0
