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
	varchar :type,       :index => true
	int     :address_id, :index => true
end unless DB.table_exists?( :edges )

DB.create_table :mail_details do
	varchar :path, :unique => true
	
	text :toheader,      :index => true
	text :cc,            :index => true
	text :deliveredto,   :index => true
	text :xapparentlyto, :index => true
	
	boolean :extracted, :index => true, :default => false
	boolean :analyzed,  :index => true, :default => false
end unless DB.table_exists? :mail_details

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

log # blank line

##############################################################################
### A N A L Y S I S   P H A S E
##############################################################################

print "Analyzing #{@mail_details.filter( :analyzed => false ).size} messages"

count = 0
@mail_details.filter( :analyzed => false ).each do |msg|
	[ :toheader, :cc, :deliveredto, :xapparentlyto ].each do |column|
		next if msg[column].nil? or msg[column].empty?

		msg[ column ].split( ',' ).each do |addr|
			begin
				@addresses.insert( :address => addr )
			rescue Sequel::Error => e
				# re-raise if it's not a duplicate key error
				raise e unless e.message =~ /duplicate key value violates unique constraint "addresses_address_key"/
			ensure
				addr_id = @addresses.filter( :address => addr ).map( :id ).first
			end

			edge_type = column.to_s
			edge_type = "to" if column == :toheader

			@edges.insert( :path => msg[:path], :type => edge_type, :address_id => addr_id )
		end
	end

	@mail_details.filter( :path => msg[:path] ).update( :analyzed => true )

	count += 1

	if count % 10 == 0
		print count
	else
		print '.'
	end
end

log "...done!"
