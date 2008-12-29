#!/usr/bin/env ruby

%w(rubygems hpricot open-uri shorturl).each {|g| require g}
def fetch(url = '') ; return Hpricot(open("http://www.amazon.com" + url)) ; end
def d(msg = '') ; $stderr.puts msg ; end

d "Fetching amazon.com"
vg_url = fetch.at("a[text()=Video Games]")[:href]
d " * found video games URL: #{vg_url}"

dotd_img = fetch(vg_url).search("area").select {|e| e[:alt] =~ /Deal of the Day/}.first
d " * found dotd image href: #{dotd_img[:href]}"
dotd = fetch(dotd_img[:href])

table = dotd.at( "//table.amabot_widget" )

puts "-" * 80

puts "Title:      " + table.at( "/tr/td[3]/a" ).inner_text.strip

puts "Platform:   " + table.at( "/tr[2]/td" ).inner_html.
	match( /Platform:.*?\/>&nbsp;(.*?)$/ )[1].
	gsub( /<\/?b>/, '' ).gsub( "<br />", ' ' ) # strip out <b> and <br /> tags

puts "List Price: " + table.at( "//span[@class=listprice]" ).inner_text.strip
puts "Sale Price: " + table.at( "//b[@class=price]" ).inner_text.strip
puts "Link:       " + ShortURL.shorten( "http://www.amazon.com" + table.at( "/tr/td[3]/a" )[:href] )
