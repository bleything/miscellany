#!/usr/bin/env ruby

require 'includes/config'
require 'includes/database'
require 'includes/helpers'

##############################################################################
### F I N D   F I L E S   I N   D A T A B A S E
##############################################################################

print "Fetching files from the database..."

hashed_files        = @mp3s.filter( :hashed => true        ).map( :path )
fingerprinted_files = @mp3s.filter( :fingerprinted => true ).map( :path )

log "done!"

log # blank line

log "Found #{@mp3s.count} files, of which:"
log "  * #{hashed_files.size} have been hashed, and"
log "  * #{fingerprinted_files.size} have been fingerprinted."

log # blank line

size = 0
DB[ "SELECT pg_size_pretty( sum( size ) ) FROM mp3s" ].each {|r| size = r[:pg_size_pretty] }

log "The files in the database take up a total of #{size}."
