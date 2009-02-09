#!/usr/bin/env ruby

require 'includes/config'
require 'includes/database'
require 'includes/helpers'

##############################################################################
### S A N I T Y   C H E C K S
##############################################################################

CONFIG[ 'music_paths' ].each do |path|
  unless File.directory? path
    log "#{path} is not a directory."
    exit 1
  end
end

##############################################################################
### F I N D   F I L E S   O N   D I S K
##############################################################################

disk_files = []

CONFIG[ 'music_paths' ].each do |path|
  log "Finding files in #{path}..."
  disk_files += `find #{path.gsub( / /, '\ ' )} -type f`.split( "\n" )
end

log "...done! Found #{disk_files.size} files."

log # blank line

##############################################################################
### F I N D   F I L E S   I N   D A T A B A S E
##############################################################################

log "Fetching files from the database..."
db_files = @mp3s.map( :path )
log "...done! Found #{db_files.size} files."

log # blank line

##############################################################################
### B U I L D   W O R K I N G   S E T S
##############################################################################

log "Analyzing find results..."

# new_files are the files on disk that the database doesn't know about yet
new_files = disk_files - db_files
log " * found #{new_files.size} new files to be inserted"

log # blank line

##############################################################################
### I N S E R T   N E W   F I L E S
##############################################################################

print "Adding new files to the database"

count = 0
new_files.each do |path|
  if NON_MUSIC_EXTENSIONS.include? path.split( '.' ).last
    actually_music = false
  else
    actually_music = nil # we don't want to decide it's actually music *yet*
  end

  @mp3s.insert( :path => path, :actuallymusic => actually_music )

  count += 1

  if count % 10 == 0
    print count
  else
    print '.'
  end
end

log "...done!"

log # blank line
