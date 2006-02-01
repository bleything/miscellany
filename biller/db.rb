#!/usr/bin/env ruby

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