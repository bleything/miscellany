#!/usr/bin/env ruby

##############################################################################
### U T I L I T Y   F U N C T I O N S
##############################################################################

def log( msg = "" )
	$stderr.puts msg
end

$stdout.sync = true

##############################################################################
### S A N I T Y   C H E C K S
##############################################################################

unless ARGV[0]
	log "You must specify a directory to scan:"
	log "  #{$0} /path/to/music/files"
	exit
end

unless File.directory? ARGV[0].gsub( /\\ /, ' ' ) # strip out escaped spaces... sigh
	log "#{ARGV[0]} is not a directory."
	exit
end

##############################################################################
### D A T A B A S E   S E T U P
##############################################################################

require 'rubygems'
require 'sequel'

# Sequel database object
DB = Sequel.connect( 'postgres://localhost' )

DB.create_table :mp3s do
	text    :path, :unique => true
	int     :size

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
### F I N D   F I L E S   O N   D I S K
##############################################################################

log "Finding files in #{ARGV[0]}..."
disk_files = `find #{ARGV[0].gsub( / /, '\ ' )} -type f`.split( "\n" )
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
	@mp3s.insert( :path => path )
	
	count += 1
	
	if count % 10 == 0
		print count
	else
		print '.'
	end
end

log "...done!"

log # blank line
