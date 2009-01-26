#!/usr/bin/env ruby -w

require 'includes/database'

### Discovers all files whose sha1 hashes are the same

duplicate_sha1s = DB[ 
  "SELECT sha1                " +
  "FROM mp3s                  " +
  "WHERE sha1 IS NOT NULL AND " +
  "actuallymusic IS true      " +
  "GROUP BY sha1              " +
  "HAVING COUNT(path) > 1     " +
  "ORDER BY COUNT(path) DESC; "
]

duplicate_sha1s.each do |dupe|
  duplicate_files = DB.from( :mp3s ).
    filter( :sha1 => dupe[:sha1], :actuallymusic => true ).
    map( :path )
  
  puts dupe[:sha1]
  puts "=" * dupe[:sha1].length

  puts duplicate_files.join( "\n" )

  puts
end
