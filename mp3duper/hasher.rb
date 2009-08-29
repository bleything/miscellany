#!/usr/bin/env ruby

require 'includes/config'
require 'includes/database'
require 'includes/helpers'

##############################################################################
### F I N D   F I L E S   I N   D A T A B A S E
##############################################################################

log "Fetching files from the database..."
db_files = @mp3s.filter( :hashed => false ).map( :path )
log "...done! Found #{@mp3s.count} files, of which #{db_files.size} need to be hashed."

log # blank line

##############################################################################
### G E N E R A T E   H A S H E S   F O R   F I L E S
##############################################################################

require 'digest/md5'
require 'digest/sha1'

print "Finding hashes and sizes for #{db_files.size} files"

count = 0

db_files.each do |path|
  sha1 = Digest::SHA1.file( path ).hexdigest
  md5  = Digest::MD5.file(  path ).hexdigest
  size = File.size( path )

  @mp3s.filter( :path => path ).update(
    :sha1   => sha1,
    :md5    => md5,
    :size   => size,
    :hashed => true
  )

  # status display
  count += 1

  if ( count % 10 ) == 0
    print count
  else
    print "."
  end
end

log "...done!"
