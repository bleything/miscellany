#!/usr/bin/env ruby

require 'includes/database'

### Discovers all files whose sha1 hashes are the same
duplicate_sha1s = DB[
  "SELECT sha1                " +
  "FROM mp3s                  " +
  "WHERE sha1 IS NOT NULL     " +
  "AND ignored = false        " +
  "GROUP BY sha1              " +
  "HAVING COUNT(path) > 1     " +
  "ORDER BY COUNT(path) DESC; "
]

duplicate_sha1s.each do |dupe|
  duplicate_files = DB.from( :mp3s ).
    filter( :sha1 => dupe[:sha1] ).
    map( :path )

  puts dupe[:sha1]
  puts "=" * dupe[:sha1].length

  puts duplicate_files.sort.join( "\n" )

  puts
end
