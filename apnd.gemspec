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

  s.add_dependency('eventmachine', '= 0.12.10')
  s.add_dependency('json',         '>= 1.4.6')
  s.add_dependency('daemons',      '= 1.1.0')

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
