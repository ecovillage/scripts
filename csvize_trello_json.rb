#!/usr/bin/env ruby

# Copyright 2017 Felix Wolfsteller
# Released under the GPLv3+

# Read json as generated from trello export from file(s) or stdin,
# extract listname,cardname,membernames and export to
# csv (well, semicolon as field seperator) on stdout.

require 'json'
require 'csv'

trello_data = JSON.parse(ARGF.read)

lists   = trello_data["lists"]
cards   = trello_data["cards"]
members = trello_data["members"]

list_db   = lists.map{|l| [l["id"], l["name"]]}.to_h
member_db = members.map{|m| [m["id"], m["fullName"]]}.to_h

cards.each {|c| c["list"] = list_db[c["idList"]]}
cards.each {|c| c["members"] = member_db.values_at(*c["idMembers"])}

header = ["List name", "Card", "Members"]

csv_string = CSV.generate(col_sep: ';') do |csv|
  csv << header
  cards.each do |c|
    csv << [c["list"], c["name"], c["members"].join(',')]
  end
end

puts csv_string
