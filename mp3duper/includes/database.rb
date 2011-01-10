#!/usr/bin/env ruby

require 'includes/config'

##############################################################################
### D A T A B A S E   S E T U P
##############################################################################

require 'rubygems'
require 'sequel'

# Sequel database object
DB = Sequel.connect( CONFIG['db_uri'] )

DB.create_table :mp3s do
  primary_key :id

  text :path, :unique => true
  int  :size

  # fingerprints
  varchar :puid, :index => true
  varchar :sha1, :index => true

  # status markers
  boolean :fingerprinted, :index => true, :default => false
  boolean :hashed,        :index => true, :default => false
  boolean :ignored,       :index => true, :default => false
end unless DB.table_exists?( :mp3s )

@mp3s = DB.from( :mp3s )
