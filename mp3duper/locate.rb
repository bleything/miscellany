#!/usr/bin/env ruby

### finds all filenames that match the pattern passed in

require 'rubygems'
require 'sequel'

Sequel.connect('postgres://localhost').
  from( :mp3s ).filter( :path => /#{ARGV.join ' '}/i ).each do |mp3|

  puts mp3[:path]
end
