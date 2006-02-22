#!/usr/bin/env ruby

##############
# additem.rb #
##########################################################################
# Copyright 2006 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

require 'db'

item = Item.new
clients = Client.find_all.map {|c| c.code}.join ", "

print "Which client (#{clients})? "
item.client = Client.find_by_code(gets.chomp)

print "Enter the date (YYYY-MM-DD) of the work or leave blank for today: "
date = gets.chomp

if date.empty?
  item.item_date = Time.now.strftime('%Y-%m-%d')
else
  item.item_date = date
end

print "Enter the (decimal) number of hours spent on this item: "
item.hours = gets.chomp.to_f

print "Enter a brief description of the item: "
item.description = gets.chomp

if item.save
  puts "Item added successfully!"
else
  puts "Something happened!"
end
