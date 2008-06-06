GitHub + Fogbugz
===

This is a simple sinatra application that has three responsibilities:

* Receive and parse the JSON commit info from GitHub's post-receive hooks and send it to FogBugz
* Act as a "gateway" for viewing multiple SCM repositories in FogBugz
* Edit case history per the commit message's instructions.

To Install and Run:
---

    $ sudo gem install sinatra json
    $ mv config.yml.example config.yml
    $ rake ragel:compile # you need Ragel locally to make this work
                         # if you install as a gem, you don't need to execute this step
    $ github-fogbugz     # Copies the config file examples to ~/.github-fogbugz/config.yml
    $ ...edit config.yml (see below)...
    $ github-fogbugz-server [-p port] [-e production]

	# Send your developers here so they can authenticate to FogBugz
    $ http://localhost:<port>/login
    
Configuration
---

### GitHub repositories:
Set up your repositories on GitHub to send a [post-receive hook](http://github.com/guides/post-receive-hooks) to the root url of this sinatra app. Be sure to include the port, if other than 80.

### github-fogbugz-server (this app):
The configuration file holds several variables that you'll need to edit.

* **fb\_submit\_url**: The url to the cvsSubmit.[php|asp] file on your FogBugz server.
* **fb\_main\_url**: The url to your FogBugz's installation.
* **curl**: The path to the curl binary. Curl is used to submit the commit to FogBugz.
* **repos**: A list of the SCM repositories that you're using.  Each repo has two urls:
  * *log_url*: The url to the commit log for a specific file 
  * *diff_url*: The url to the specific commit or revision.

Each repo name must match the the values that are in the *sRepo* field in FogBug's *CVS* table.

Each developer must login to FogBugz through this app.  Visit **/login** and follow the instructions.  The act of logging in will create a tokens.yml file in the app's config directory, chmod'ed 0600.  github-fogbugz-server expects the developer's E-Mail addresses to match: github vs fogbugz.

### FogBugz:  
You'll need to do some configuration in FogBugz as well.  As the FogBugz admin, edit your site settings, and in the source control urls for logs and diffs, enter:

* Logs: "http://thisapp:port/repo_url?type=log&repo=^REPO&file=^FILE&r1=^R1&r2=^R2" 
* Diffs: "http://thisapp:port/repo_url?type=diff&repo=^REPO&file=^FILE&r1=^R1&r2=^R2"

The only difference between the two is the "type" parameter.

> I'm not a fan of Fog Creek's [suggested solution](http://www.fogcreek.com/FogBugz/KB/howto/MultipleRepositories-Mult.html) for multiple repositories, as it requires you to copy a new script into the FogBugz website directory. This seems fine, but (as is my understanding) you'll have to copy it over again and again with each FogBugz upgrade because the website directory gets recreated each time. That's why this script also acts as the SCM viewer "gateway."

**Note:** If you've been using FogBugz in the past with only a single repository, odds are your *sRepo* field is empty. Mine was. Be sure that all of the records in FogBugz's *CVS* table have a valid *sRepo* that matches up to a repo specified in the config file.

Other Notes
---
When parsing out the file names from github commits, I've tacked on the branch that the file lives on.  So in FogBugz you'll see files like "master/myfile.rb".  This is simply because my team does the "release on a branch" thing (aka [Release Line](http://www.scmpatterns.com/book/pattern-summary.html)), and I like to see which branch certain bugs were fixed on.  Feel free to modify this behavior.

Caveats
---
It's fairly obvious that FogBugz was written for a more traditional CVS/SVN SCM system in mind. As such, the commit list display doesn't really jive with git:

![Messy Commits List in FogBugz](http://img.skitch.com/20080424-kb6kujbfd224436pqgnhgj33sk.jpg)

This is in FogBugz 6.1.23.  I've got a [thread started](http://support.fogcreek.com/default.asp?fogbugz.4.24526.0) on their forum asking for this to be cleaned up a bit. We'll see if it gets better in future releases.

Thanks
---
Inspired by [github-campfire](http://github.com/jnewland/github-campfire) by [jnewland](http://github.com/jnewland) and
[github-twitter](http://github.com/jnunemaker/github-twitter) by [jnunemaker](http://github.com/jnunemaker). 

License
---
MIT.  See LICENSE file.
