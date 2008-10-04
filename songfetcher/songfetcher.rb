#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

url = URI.parse( ARGV[0] )

doc = Hpricot( open( url.to_s ) )

doc.search( '//a' ).select {|a| a['href'] =~ /mp3/i }.each do |a|
	`wget #{url.scheme}://#{url.host}#{a['href']}`
end

