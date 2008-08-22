#!/usr/bin/env ruby

require 'rubygems'
require 'sequel'

# Sequel database object
DB = Sequel.connect( 'postgres://localhost' )

DB.create_table :addresses do
	serial :id,       :index => true
	varchar :address, :index => true
end unless DB.table_exists?( :addresses )

DB.create_table :edges do
	varchar :path,       :index => true
	varchar :edge_type,  :index => true
	int     :address_id, :index => true
end unless DB.table_exists?( :edges )
