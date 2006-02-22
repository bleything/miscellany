#!/usr/bin/env ruby

#########
# db.rb #
##########################################################################
# Copyright 2006 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

require 'rubygems'
require_gem 'activerecord'

ActiveRecord::Base.establish_connection( {
  :adapter  => 'postgresql',
  :database => 'biller',
  :host     => 'localhost',
  :username => 'biller',
  :password => 'biller'
})

class Client < ActiveRecord::Base
  has_many :items
  has_many :invoices
end

class Item < ActiveRecord::Base
  belongs_to :client
  belongs_to :invoice
end

class Invoice < ActiveRecord::Base
  has_many :items
end
