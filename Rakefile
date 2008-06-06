require "rubygems"
require "rake/testtask"
require "rake/gempackagetask"

GEM = "github-fogbugz"
VERSION = "0.0.2"
AUTHOR = ["John Reilly", "François Beausoleil"]
EMAIL = ["jr@trms.com", "francois@teksol.info"]
HOMEPAGE = "http://github.com/johnreilly/github-fogbugz"
SUMMARY = "A gem that acts as the gateway between GitHub and Fogbugz."

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.markdown", "LICENSE", "TODO"]
  s.summary = SUMMARY
  s.description = s.summary
  s.authors = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.executables = ["github-fogbugz-server", "github-fogbugz"]
  
  # Uncomment this to add a dependency
  s.add_dependency "json", "~> 1.1.2"
  
  s.require_path = "lib"

  # Must reference lib/message_parser.rb explicitely, or it won't be automatically generated
  s.files = %w(LICENSE README.markdown Rakefile TODO lib/message_parser.rb) + Dir.glob("{lib,test,config,samples,bin}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{VERSION}}
end

Rake::TestTask.new("test" => "lib/message_parser.rb") do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
end

task :default => :test

file "lib/message_parser.rb" => "lib/message_parser_machine.rb" do
  sh "ragel -R lib/message_parser_machine.rb -o lib/message_parser.rb"
end

file "tmp/machine.dot" => "lib/message_parser_machine.rb" do
  sh "ragel -V lib/message_parser_machine.rb -o tmp/machine.dot"
end

file "tmp/machine.png" => "tmp/machine.dot" do
  sh "dot -Tpng tmp/machine.dot > tmp/machine.png"
end

namespace :ragel do
  desc "Compile the Ragel state machine to executable Ruby code"
  task :compile => "lib/message_parser.rb"

  desc "Generate tmp/machine.png"
  task :graph => "tmp/machine.png"

  desc "Delete generated Ragel files"
  task :clean do
    rm_f "lib/message_parser.rb"
    rm_f "tmp/machine.dot"
    rm_f "tmp/machine.png"
  end
end

task :ragel => %w(ragel:compile ragel:graph)

desc "Remove all generated files"
task :clean => "ragel:clean" do
  rm_rf "pkg"
end