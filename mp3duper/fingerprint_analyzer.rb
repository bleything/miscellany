#!/usr/bin/env ruby

require 'includes/database'

### Discovers all files whose acoustic fingerprints are the same
duplicate_puids = DB[
  "SELECT puid                " +
  "FROM mp3s                  " +
  "WHERE puid IS NOT NULL     " +
  "GROUP BY puid              " +
  "HAVING COUNT(path) > 1     " +
  "ORDER BY COUNT(path) DESC; "
]

duplicate_puids.each do |dupe|
  duplicate_files = DB.from( :mp3s ).
    filter( :puid => dupe[ :puid ] )

  next unless duplicate_files.count > 1

  puts dupe[:puid]
  puts "=" * dupe[:puid].length

  duplicate_files.sort_by {|d| d[:path] }.each do |dupe|
    puts "#{dupe[:size]} -- #{dupe[:path]}"
  end

  puts
end
