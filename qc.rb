#!/usr/bin/env ruby

require 'csv'

opts = { col_sep: "\t", headers: true, quote_char: "\x00" }
resolver_file = CSV.open('match_resolver.csv', opts)

matches = resolver_file.map { |r| r['matchedType'] }.uniq

obj = matches.each_with_object({}) do |m, h|
  h[m] = {}
end

resolver_file.each_with_object(obj) do |r, h|
  obj[r]
end
