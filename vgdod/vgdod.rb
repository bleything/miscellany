#!/opt/local/bin/ruby

%w(rubygems hpricot open-uri).each {|g| require g}
def fetch(url = '') ; return Hpricot(open("http://www.amazon.com" + url)) ; end

vg_url = fetch.at("a[text()=Video Games]")[:href]
dotd_map = fetch(vg_url).search("map").select {|e| e[:name] =~ /dotd/}.first
dotd = fetch(dotd_map.at("area")[:href])
# dotd = fetch("/Microsoft-9UE-00001-Halo-3/dp/B000FRU0NU/ref=pd_bbs_sr_1/103-5342003-6915053?ie=UTF8&s=videogames&qid=1194816939&sr=8-1")

# title -- platform -- price -- url
puts [
  dotd.at("//div.buying//b.sans").inner_text.strip,
  dotd.search("//td/b.price").last.inner_text.strip,
  dotd.search("//div[@class=buying]")[3].inner_text.gsub(/(\&nbsp;|Platform:)/, '').strip,
].join( " -- " )
