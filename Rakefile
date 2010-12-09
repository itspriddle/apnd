require 'rubygems'

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test' << '.'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/apnd.rb -I ./lib"
end

require 'sdoc_helpers'
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
  exec "rake pages"
end
