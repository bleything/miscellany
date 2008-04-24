#!/usr/bin/env ruby

%w(rubygems hpricot open-uri shorturl).each {|g| require g}
def fetch(url = '') ; return Hpricot(open("http://www.amazon.com" + url)) ; end

vg_url = fetch.at("a[text()=Video Games]")[:href]
puts " * found video games URL: #{vg_url}" if $DEBUG

dotd_img = fetch(vg_url).search("img").select {|e| e[:src] =~ /deal-of-the-day/}.first
puts " * found dotd image href: #{dotd_img.parent[:href]}" if $DEBUG

dotd = fetch(dotd_img.parent[:href])


table = dotd.at( "//table.amabot_widget" )


puts "Title:      " + table.at( "/tr/td[3]/a" ).inner_text.strip
puts "Platform:   " + table.at( "/tr[2]/td" ).inner_text.match( /Platform: ..(.*?)Video Game/ )[1]
puts "List Price: " + table.at( "//span[@class=listprice]" ).inner_text.strip
puts "Sale Price: " + table.at( "//b[@class=price]" ).inner_text.strip
puts "Link:       " + ShortURL.shorten( "http://www.amazon.com" + table.at( "/tr/td[3]/a" )[:href] )
