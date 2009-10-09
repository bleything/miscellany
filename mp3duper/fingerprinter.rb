#!/usr/bin/env ruby

require 'includes/config'
require 'includes/database'
require 'includes/helpers'

##############################################################################
### F I N D   F I L E S   I N   D A T A B A S E
##############################################################################

log "Fetching files from the database..."
db_files = @mp3s.
  filter(  :fingerprinted => false, :actuallymusic => nil ).map( :path )

log "...done! Found #{@mp3s.count} files, of which #{db_files.size} need to be fingerprinted."

log # blank line

##############################################################################
### S A N I T Y   C H E C K S
##############################################################################

unless File.exists? 'genpuid/genpuid'
  log "Can't find genpuid executable.  Make sure there's a directory called genpuid with a genpuid executable inside it."
  exit 1
end

##############################################################################
### F I N G E R P R I N T   T I E M ! ! ! 1
##############################################################################
print "Finding PUIDs for #{db_files.size} files..."

count = 0

db_files.each do |path|
  output = `genpuid/genpuid #{CONFIG['musicdns_key']} "#{path}"`

  if output =~ /Incorrect MusicDNS key/
    log "MusicDNS rejected your key.  Please check their site and update your config.yml."
    exit 1
  end

  # mark the file as seen so we'll skip it next time even if there's no
  # PUID.  This prevents us from cranking over the same broken files every
  # time we start up
  @mp3s.filter( :path => path ).update( :fingerprinted => true )

  # if puid
  if puid = output.match( /puid: (.*)$/ )[1] rescue nil
    # update with the new PUID
    @mp3s.filter( :path => path ).update( :puid => puid )
    symbol = '+'
  else
    # if we don't get a PUID out of genpuid, let's just move along
    symbol = '.'
  end

  # status display
  count += 1

  if ( count % 10 ) == 0
    print count
  else
    print symbol
  end
end

log "...done!"

