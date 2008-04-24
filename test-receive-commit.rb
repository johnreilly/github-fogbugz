require 'net/http'

payload = %Q{
  {"commits":
    { "a72c48d7335486b50b29ef31bb3f694febb9cc62":
      { "removed":["ghook.rb"],
        "author":{"name":"John Reilly","email":"jr@trms.com"},
        "added":[".gitignore","config.yml.example","github-fogbugz.rb"],
        "timestamp":"2008-04-23T12:46:10-07:00",
        "modified":[],
        "message":"bugzid: 3083 slight refactoring",
        "url":"http:\/\/github.com\/johnreilly\/fbtest\/commit\/a72c48d7335486b50b29ef31bb3f694febb9cc62"},
      "ae0b864ad73325c4e8f5c195cd9a9a33cd73e46b":
      { "removed":[],
        "author":{"name":"John Reilly","email":"jr@trms.com"},
        "added":["github-fogbugz-test.rb"],
        "timestamp":"2008-04-23T13:30:12-07:00",
        "modified":["github-fogbugz.rb"],
        "message":"bugzid: 3083 adding some tests",
        "url":"http:\/\/github.com\/johnreilly\/fbtest\/commit\/ae0b864ad73325c4e8f5c195cd9a9a33cd73e46b"}},
    "after":"ae0b864ad73325c4e8f5c195cd9a9a33cd73e46b",
    "before":"6254706d8facde1191f2a96e27200f6057ccc14e",
    "ref":"refs\/heads\/master",
    "repository":
      { "name":"fbtest",
        "owner":{"name":"johnreilly","email":"jr@trms.com"},
        "url":"http:\/\/github.com\/johnreilly\/fbtest"}}}
 
url = URI.parse('http://localhost:4567/')
req = Net::HTTP::Post.new(url.path)
req.set_form_data({'payload' => payload})
res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
puts res