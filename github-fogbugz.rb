require 'rubygems'
require 'json'
require 'sinatra'
require 'yaml'
require 'cgi'

# This sinatra app has two endpoints:
#  /              This is where GitHub will send 
#                 its post-receive hooks
#
#  /repo_url      This is where FogBugz will send 
#                 you when you click on a commit link


##
# GitHub should send its post-receive hook here.
post '/' do
  GithubFogbugz.new(params[:payload])
end

## 
# Set the log and diff urls (in fogbugz's site settings) to point here.
# Log url:  http://localhost:4567/repo_url?type=log&repo=^REPO&file=^FILE&r1=^R1&r2=^R2
# Diff url: http://localhost:4567/repo_url?type=diff&repo=^REPO&file=^FILE&r1=^R1&r2=^R2
get '/repo_url' do
  config = YAML.load_file('config.yml')

  #pull out the repo's scm viewer url from the config file
  if params[:type] == 'log'
    url = config['repos'][params[:repo]]['log_url']
  elsif params[:type] == 'diff'
    url = config['repos'][params[:repo]]['diff_url']
  else
    "Unknown repo viewer type."
  end
  
  if url
    url.gsub!(/\^REPO/, params[:repo])
    url.gsub!(/\^FILE/, params[:file])
    url.gsub!(/\^R1/, params[:r1])
    url.gsub!(/\^R2/, params[:r2])
    redirect url
  end
    
end




##
# This class does all of the json parsing and submits a push's commits to fogbugz
class GithubFogbugz
  
  def initialize(payload)
    config = YAML.load_file('config.yml')
    
    payload = JSON.parse(payload)
    return unless payload.keys.include?("repository")
    
    repo = payload["repository"]["name"]
    branch = payload["ref"].split('/').last
    
    payload["commits"].each do |c|
      process_commit(c.first, c.last, repo, branch, payload['before'], config['fb_submit_url'], config['curl'])
    end
    
  end
  
  def process_commit(sha1, commit, repo, branch, before, fb_submit_url, curl_path)
    
    # from each commit in the payload, we need to extract:
    # - name of repo, renamed as "github-<repo>"
    # - name of file, including branch. e.g.: "4.7/Builds/Cablecast.fbp4"
    # - sha1 of commit (R2)
    # - sha1 of before (R1)
    # - bugzid (found inside the commit message)
    
    message = commit["message"]
    files = commit["removed"] | commit["added"] | commit["modified"]
    
    # look for a bug id in each line of the commit message
    bug_list = []
    message.split("\n").each do |line|
      if (line =~ /\s*Bug[zs]*\s*IDs*\s*[#:; ]+((\d+[ ,:;#]*)+)/i)
        bug_list << $1.to_i
      end
    end
    
    # for each found bugzid, submit the files to fogbugz.
    # this will set the sRepo to "github-<repo>", which will be used above
    # when fogbugz asks for the scm viewer url.
    bug_list.each do |fb_bugzid|
      files.each do |f|
        fb_repo = CGI.escape("github-#{repo}")
        fb_r1 = CGI.escape("#{before}")
        fb_r2 = CGI.escape("#{sha1}")
        fb_file = CGI.escape("#{branch}/#{f}")
        
        #build the GET request, and send it to fogbugz
        fb_url = "#{fb_submit_url}?ixBug=#{fb_bugzid}&sRepo=#{fb_repo}&sFile=#{fb_file}&sPrev=#{fb_r1}&sNew=#{fb_r2}"
        puts `#{curl_path} --insecure --silent --output /dev/null '#{fb_url}'`

      end
    end
  end
end
