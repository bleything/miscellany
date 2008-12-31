#!/usr/bin/env ruby

##############################################################################
### U T I L I T Y   F U N C T I O N S
##############################################################################

def log( msg = "" )
  $stderr.puts msg
end

$stdout.sync = true

##############################################################################
### D A T A B A S E   S E T U P
##############################################################################

require 'rubygems'
require 'sequel'

# Sequel database object
DB = Sequel.connect( 'postgres://localhost' )

DB.create_table :mp3s do
  text :path, :unique => true
  int  :size
  
  # fingerprints
  varchar :puid, :index => true
  varchar :sha1, :index => true
  varchar :md5,  :index => true
  
  # status markers
  boolean :fingerprinted, :index => true, :default => false
  boolean :hashed,        :index => true, :default => false
end unless DB.table_exists?( :mp3s )

@mp3s = DB.from( :mp3s )

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

log "Checking #{db_files.size} files"

count = 0

db_files.each do |path|
  begin
    File.stat path
  rescue Errno::ENOENT
    # file does not exist, remove it
    @mp3s.filter( :path => path ).delete
    
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
