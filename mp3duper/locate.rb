#!/usr/bin/env ruby

require 'includes/database'

### finds all filenames that match the pattern passed in
@mp3s.filter( :path => /#{ARGV.join ' '}/i ).each {|mp3| puts mp3[:path] }
