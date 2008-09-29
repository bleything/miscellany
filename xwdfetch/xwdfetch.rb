#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

url = ARGV[0]

doc = Hpricot( open( url ) )
base_url = doc.at( 'base' )[ 'href' ]
puzzles = doc.search( 'a' ).map {|e| e['href'] }.select {|fn| fn =~ /puz$/}

puzzles.map {|puz| base_url + puz }.each do |url|
  `curl -O #{url}`
end
