#!/usr/bin/env ruby

################
# addclient.rb #
##########################################################################
# Copyright 2006 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

require 'db'

client = Client.new

print "Enter client name: "
client.name = gets.chomp

print "Enter client short code: "
client.code = gets.chomp

print "To whom does the invoice go? "
client.towho = gets.chomp

if client.save
  puts "Client created successfully!"
else
  puts "Some error occured!"
end
