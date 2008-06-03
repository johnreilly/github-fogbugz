require "rubygems"
require "rake/testtask"
require "rake/gempackagetask"

GEM = "github-fogbugz"
VERSION = "0.0.1"
AUTHOR = ["John Reilly", "François Beausoleil"]
EMAIL = ""
HOMEPAGE = "http://github.com/johnreilly/github-fogbugz"
SUMMARY = "A gem that acts as the gateway between GitHub and Fogbugz."

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # Uncomment this to add a dependency
  s.add_dependency "activesupport", "~> 2.0"
  
  s.require_path = "lib"
  s.autorequire = GEM
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,test}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{VERSION}}
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
end

task :default => :test
