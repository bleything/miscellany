#!/usr/bin/env ruby

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