#!/usr/bin/env ruby
#
# = analyzer.rb
#
# Looks at your Springboard plist file and updates your appmap with any new
# applications it finds.
# 

require 'rubygems'
require 'plist'
require 'yaml'

# try to load the appmap... if it doesn't exist, use an empty hash
begin
  appmap = YAML.load_file( 'appmap.yml' )
rescue
  appmap = { 'identifierMap' => {}, 'unknownIdentifiers' => [] }
end

# for this script, we only need the identifiers, so pull them out if
# they've already been mapped.
mapped_applications  = appmap[ 'identifierMap'      ].collect { |k,v| v }
unknown_applications = appmap[ 'unknownIdentifiers' ]

puts "Found #{mapped_applications.size} mapped applications" unless mapped_applications.empty?
puts "Found #{unknown_applications.size} unknown applications" unless unknown_applications.empty?


# load up the springboard plist and fetch the app list
springboard_plist = Plist.parse_xml( 'com.apple.springboard.plist' )
springboard_apps  = springboard_plist[ "iconState" ][ "iconLists" ].
  collect { |page| page[ "iconMatrix" ] }.
  flatten.
  select  { |entry| entry.is_a? Hash }.
  collect { |entry| entry[ "displayIdentifier" ] }

# remove existing, known applications from the list
new_applications = springboard_apps - mapped_applications - unknown_applications
puts "Found #{new_applications.size} new applications"

# make a backup of the appmap, add the new apps to the unknown list, and save
# it out.
if File.exists? 'appmap.yml'
  backup_filename = "appmap.yml.backup-#{Time.now.strftime '%Y%m%d_%H%M%S'}"
  puts "Made backup of appmap.yml at #{backup_filename}"
  FileUtils.cp 'appmap.yml', backup_filename rescue nil
end

appmap[ 'unknownIdentifiers' ] += new_applications
File.open( 'appmap.yml', 'w' ) do |fh|
  fh.write YAML.dump( appmap )
  puts "Wrote appmap.yml"
end
