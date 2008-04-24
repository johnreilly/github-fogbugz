require 'net/http'
require 'cgi'

 
url = URI.parse('http://localhost:4567/repo_url')
req = Net::HTTP::Get.new(url.path)
req.set_form_data(:type => "diff", :repo => "cvs", :file => "filename.rb", :r1 => "123", :r2 => "124")
res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }


req.set_form_data(:type => "log", :repo => "github-fbtest", :file => "4.7/filename.rb", :r1 => "123", :r2 => "124")
res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }