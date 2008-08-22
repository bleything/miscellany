#!/usr/bin/env ruby

##############################################################################
### U T I L I T Y   F U N C T I O N S
##############################################################################

def log( msg = nil )
	$stderr.puts msg
end

##############################################################################
### S A N I T Y   C H E C K S
##############################################################################

unless ARGV[0]
	log "You must specify a directory to scan:"
	log "  #{$0} /path/to/Maildir"
	exit
end

unless File.directory? ARGV[0]
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
@mail_details = DB.from( :mail_details )

DB.create_table :mail_details do
	varchar :path, :unique => true
	
	text :toheader,      :index => true
	text :cc,            :index => true
	text :deliveredto,   :index => true
	text :xapparentlyto, :index => true
	
	boolean :detailed, :index => true
	boolean :analyzed, :index => true
end unless DB.table_exists? :mail_details

##############################################################################
### F I N D   F I L E S   O N   D I S K
##############################################################################

log "Finding files in #{ARGV[0]}..."
disk_files = `find #{ARGV[0]} -type f`.split( "\n" )
log "...done! Found #{disk_files.size} files."

log # blank line

##############################################################################
### F I N D   F I L E S   I N   D A T A B A S E
##############################################################################

log "Fetching files from the database..."
db_files = []
DB[ 'select path from mail_details' ].each do {|row| db_files << row[:path] }
log "...done! Found #{db_files.size} files."

log # blank line

##############################################################################
### B U I L D   W O R K I N G   S E T S
##############################################################################

log "Analyzing find results..."

# new_files are the files on disk that the database doesn't know about yet
new_files = disk_files - db_files
log " * found #{new_files.size} new files to be inserted"

# missing_files are the files in the database that are no longer on disk
missing_files = db_files - disk_files
log " * #{missing_files.size} files need to be removed from the database"

log # blank line

##############################################################################
### I N S E R T   N E W   F I L E S
##############################################################################

# no-op

##############################################################################
### P U R G E   O L D   F I L E S
##############################################################################

# no-op
