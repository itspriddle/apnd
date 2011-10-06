$LOAD_PATH.unshift 'lib'

require 'apnd/version'

Gem::Specification.new do |s|
  s.name             = 'apnd'
  s.version          = APND::Version
  s.date             = Time.now.strftime('%Y-%m-%d')
  s.summary          = 'APND: Apple Push Notification Daemon sends Apple Push Notifications to iPhones'
  s.homepage         = 'http://github.com/itspriddle/apnd'
  s.authors          = ['Joshua Priddle']
  s.email            = 'jpriddle@nevercraft.net'

  s.files            = %w[ Rakefile README.markdown HISTORY.markdown ]
  s.files           += Dir['bin/**/*']
  s.files           += Dir['lib/**/*']
  s.files           += Dir['test/**/*']

  s.executables      = ['apnd']

  s.add_dependency('eventmachine', '>= 0.12.10')
  s.add_dependency('json',         '>= 1.4.6')
  s.add_dependency('daemons',      '>= 1.1.0')

  s.add_dependency('mongo', '= 1.3.1')
  s.add_dependency('bson', '= 1.3.1')
  s.add_dependency("mongo_mapper", ["= 0.9.1"])

  # Uncomment if you want to use this optimized version of bson that
  # requires local building
  #s.add_dependency("bson_ext", ["= 1.3.1"])

  s.add_development_dependency('sdoc', '~> 0.3.11')
  s.add_development_dependency('rake', '>= 0.8.7')
  s.add_development_dependency('shoulda-context')
  s.add_development_dependency('sdoc-helpers')
  s.add_development_dependency('rdiscount')

  s.extra_rdoc_files = ['README.markdown']
  s.rdoc_options     = ["--charset=UTF-8"]

  s.description = <<-DESC
    APND (Apple Push Notification Daemon) is a ruby library to send Apple Push
    Notifications to iPhones.
  DESC
end
