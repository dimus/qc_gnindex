#!/usr/bin/env ruby

require 'csv'

def row_item(r)
  accepted_name = r['acceptedName']
  accepted_name = nil if accepted_name == r['matchedName']
  { verbatim: r['scientificName'], input: r['inputName'],
    match: r['matchedName'],
    ed: r['matchedEditDistance'], accepted: accepted_name,
    score: r['matchedScore'] }
end

def collect_data(file)
  matches = file.map { |r| r['matchedType'] }.uniq
  obj = matches.each_with_object({}) do |m, h|
    h[m] = {}
  end

  file.rewind

  file.each_with_object(obj) do |r, o|
    if o[r['matchedType']][r['taxonID']]
      o[r['matchedType']][r['taxonID'].to_sym] << row_item(r)
    else
      o[r['matchedType']][r['taxonID'].to_sym] = [row_item(r)]
    end
  end
end

def space
  puts "\n\n\n"
end

opts = { col_sep: "\t", headers: true, quote_char: "\x00" }
resolver_file = CSV.open('match_resolver.csv', opts)
gnindex_file = CSV.open('match_gnindex.csv', opts)

resolver = collect_data(resolver_file)
gnindex = collect_data(gnindex_file)

exact_match_diff = resolver['Exact string match'].keys -
                   gnindex['Exact string match'].keys

space

puts "EXACT MATCHES UNIQUE TO RESOLVER\n\n"
exact_match_diff.each do |k|
  puts "%s: %s" % [k ,resolver['Exact string match'][k]]
  puts
end

space

canonical_match_diff = resolver['Canonical form exact match'].keys -
                       gnindex['Canonical form exact match'].keys

puts "EXACT CANONICAL MATCHES UNIQUE FOR RESOLVER\n\n"
canonical_match_diff.each do |k|
  puts "%s: %s" % [k ,resolver['Canonical form exact match'][k]]
  puts
end

space

canonical_match_diff = gnindex['Canonical form exact match'].keys -
  resolver['Canonical form exact match'].keys


puts "EXACT CANONICAL MATCHES UNIQUE FOR GNINDEX\n\n"
canonical_match_diff.each do |k|
  puts "%s: %s" % [k ,gnindex['Canonical form exact match'][k]]
  puts
end

space

canonical_fuzzy_diff = gnindex['Canonical form fuzzy match'].keys -
  resolver['Canonical form fuzzy match'].keys

puts "FUZZY MATCHES UNIQUE FOR GNINDEX\n\n"
canonical_fuzzy_diff.each do |k|
  puts "%s: %s" % [k ,gnindex['Canonical form fuzzy match'][k]]
  puts
end

space

canonical_fuzzy_diff = resolver['Canonical form fuzzy match'].keys - gnindex['Canonical form fuzzy match'].keys

puts "FUZZY MATCHES UNIQUE FOR RESOLVER\n\n"
canonical_fuzzy_diff.each do |k|
  puts "%s: %s" % [k ,resolver['Canonical form fuzzy match'][k]]
  puts
end

