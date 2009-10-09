#!/usr/bin/env ruby

require 'includes/config'
require 'includes/database'
require 'includes/helpers'

##############################################################################
### F I N D   F I L E S   I N   D A T A B A S E
##############################################################################

log "Fetching files from the database..."
db_files = @mp3s.map( :path )
log "...done! Found #{db_files.size} files."

log # blank line

##############################################################################
### S E A R C H   F O R   M I S S I N G   F I L E S
##############################################################################

print "Checking #{db_files.size} files"

count = 0
missing_files = []

db_files.each do |path|
  begin
    File.stat path
  rescue Errno::ENOENT
    # file does not exist
    missing_files << path

    symbol = '-'
  else
    symbol = '.'
  end

  count += 1

  if( count % 10 ) == 0
    print count
  else
    print symbol
  end
end

log "...done!"
log # blank line

##############################################################################
### C O N F I R M A T I O N   A N D   C L E A N U P
##############################################################################

if missing_files.empty?
  log "Didn't find any missing files; exiting."
  exit
end

log "Found #{missing_files.size} missing files."
log # blank line

input = nil

# we only exit the loop when we remove the files or quit
until input =~ /^(remove|quit)$/
  input = ask "Enter 'review' to see the list, 'remove' to remove those " +
    "entries from the database, or 'quit' to exit without changing anything: "

  log # blank line

  if input == 'review'
    log "Missing files:"
    missing_files.each {|f| log " - #{f}"}

    log # blank line

    # we want to start the loop over
    input = nil
  end
end

if input == 'quit'
  log "No changes made; exiting."
  exit
else
  print "Removing #{missing_files.size} files from the database"

  count = 0
  missing_files.each do |path|
    @mp3s.filter( :path => path ).delete
    count += 1

    if( count % 10 ) == 0
      print count
    else
      print '.'
    end
  end

  log "... done!"
end
