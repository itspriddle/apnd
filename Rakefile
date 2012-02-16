$:.unshift 'lib'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  puts "Please run `bundle install' first"
  exit
end

RSpec::Core::RakeTask.new :spec do |t|
  t.rspec_opts = %w[--color --format documentation]
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/apnd.rb -I ./lib"
end

#require 'sdoc_helpers'
desc "Push a new version to Gemcutter"
task :publish do
  require 'apnd/version'

  ver = APND::Version

  sh "gem build apnd.gemspec"
  sh "gem push apnd-#{ver}.gem"
  sh "git tag -a -m 'APND v#{ver}' v#{ver}"
  sh "git push origin v#{ver}"
  sh "git push origin master"
  sh "git clean -fd"
end

task :default => :spec
