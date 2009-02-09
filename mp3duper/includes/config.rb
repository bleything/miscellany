#!/usr/bin/env ruby

require 'yaml'

##############################################################################
### C O N F I G U R A T I O N
##############################################################################

# load the config file
CONFIG = YAML.load_file( 'config.yml' )

# we're going to be printing out a lot of status information in the
# form of dots, so sync STDOUT so it flushes on every bit of output
$stdout.sync = true

# this was arrived at by the following:
#
# good_extensions = @mp3s.exclude( :puid => nil ).map( :path ).map {|f| f.split('.').last}.sort.uniq
# bad_extensions = @mp3s.filter( :puid => nil ).map( :path ).map {|f| f.split('.').last}.sort.uniq
# NON_MUSIC_EXTENSIONS = bad_extensions - good_extensions
NON_MUSIC_EXTENSIONS = [
  "DS_Store", "JPG", "aa", "asd", "bmp", "cue", "db", "doc", "gif",
  "html", "ini", "jpg", "log", "m3u", "m4p", "m4r", "m4v", "mov",
  "nfo", "pdf", "plist", "png", "pun", "rar", "sfk", "sfv", "txt",
  "url", "wma", "zip"
]
