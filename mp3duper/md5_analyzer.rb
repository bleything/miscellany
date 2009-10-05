#!/usr/bin/env ruby

require 'includes/database'

### Discovers all files whose md5 hashes are the same

duplicate_md5s = DB[
  "SELECT md5                " +
  "FROM mp3s                 " +
  "WHERE md5 IS NOT NULL AND " +
  "actuallymusic IS true     " +
  "GROUP BY md5              " +
  "HAVING COUNT(path) > 1    " +
  "ORDER BY COUNT(path) DESC;"
]

duplicate_md5s.each do |dupe|
  duplicate_files = DB.from( :mp3s ).
    filter( :md5 => dupe[:md5], :actuallymusic => true ).
    map( :path )

  puts dupe[:md5]
  puts "=" * dupe[:md5].length

  puts duplicate_files.join( "\n" )

  puts
end
