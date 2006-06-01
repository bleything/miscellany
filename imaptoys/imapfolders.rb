#!/usr/bin/env ruby

require 'net/imap'
require 'yaml'

CREDENTIALS = YAML.load(File.open('credentials.yml'))

begin
  imap = Net::IMAP.new(CREDENTIALS[:server])
  imap.authenticate('CRAM-MD5', CREDENTIALS[:username], CREDENTIALS[:password])
rescue Net::IMAP::NoResponseError => e
  puts "IMAP authentication failed: #{e}"
rescue SocketError => e
  puts "IMAP connection failed: #{e}"
ensure
  exit if e
end

puts imap.list('', '*').map {|m| m.name}