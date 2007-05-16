#!/usr/bin/env ruby

%w(rubygems hpricot open-uri shorturl).each {|g| require g}
def fetch(url = '') ; return Hpricot(open("http://www.amazon.com" + url)) ; end

vg_url = fetch.at("a[text()=Video Games]")[:href]
dotd_img = fetch(vg_url).search("img").select {|e| e[:src] =~ /deal-of-the-day/}.first
dotd = fetch(dotd_img.parent[:href])

# title -- platform -- price -- url
printf "%s -- %s -- %s -- %s",
	dotd.at("//div.buying//b.sans").inner_text.strip,
	dotd.search("//b.price").last.inner_text.strip,
	dotd.search("//div[@class=buying]")[3].inner_text.gsub(/(\&nbsp;|\s|Platform:)/, ''),
	WWW::ShortURL.shorten("http://www.amazon.com#{dotd_img.parent[:href]}")
