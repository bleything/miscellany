#!/usr/bin/env ruby

require 'readline'

##############################################################################
### U T I L I T Y   F U N C T I O N S
##############################################################################

def log( msg = "" )
  $stderr.puts msg
end

def ask( msg = "Input: " )
  return Readline.readline( msg ).strip
end
