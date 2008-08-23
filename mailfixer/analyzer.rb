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

DB.create_table :addresses do
	serial :id,       :index  => true
	varchar :address, :unique => true
end unless DB.table_exists?( :addresses )

DB.create_table :edges do
	varchar :path,       :index => true
	varchar :edge_type,  :index => true
	int     :address_id, :index => true
end unless DB.table_exists?( :edges )

@mail_details = DB.from( :mail_details )
@addresses    = DB.from( :addresses    )
@edges        = DB.from( :edges        )

##############################################################################
### E X T R A C T I O N   P H A S E
##############################################################################

require 'tmail'

print "Extracting details from %i messages" % 
	[ @mail_details.filter( :extracted => false ).size ]

count = 0
@mail_details.filter( :extracted => false ).each do |msg|
	begin
		mail = TMail::Mail.load( msg[:path] )
	rescue TMail::SyntaxError
		# Couldn't parse the message... that either means that it wasn't an
		# email (header cache or courier metadata, for instance) or that it
		# is malformed.
		next
	end
	
	to = mail.to.select {|addr| addr =~ /bleything.net/ }.join( "," ) rescue ""
	cc = mail.cc.select {|addr| addr =~ /bleything.net/ }.join( "," ) rescue ""
	
	deliveredto   = mail.header[ 'delivered-to'    ].to_s
	xapparentlyto = mail.header[ "x-apparently-to" ].to_s
	
	deliveredto   = '' unless deliveredto   =~ /bleything.net/
	xapparentlyto = '' unless xapparentlyto =~ /bleything.net/
	
	@mail_details.filter( :path => msg[:path] ).update(
		:toheader      => to,
		:cc            => cc,
		:deliveredto   => deliveredto,
		:xapparentlyto => xapparentlyto,
		:extracted     => true
	)
	
	count += 1
	
	if count % 10 == 0
		print count
	else
		print '.'
	end
end

log "...done!"