#!/usr/bin/env ruby

require 'yaml'

##############################################################################
### C O N F I G U R A T I O N
##############################################################################

# load the config file
CONFIG = YAML.load_file( 'config.yml' )

# we're going to be printing out a lot of status information in the
# form of dots, so sync STDOUT so it flushes on every bit of output
$stdout.sync = true
