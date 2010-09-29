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

  s.files            = %w[ Rakefile README.markdown ]
  s.files           += Dir['bin/**/*']
  s.files           += Dir['lib/**/*']
  s.files           += Dir['test/**/*']

  s.executables      = ['apnd', 'apnd-push']

  s.add_dependency('eventmachine')
  s.add_dependency('json')
  s.add_dependency('daemons')

  s.extra_rdoc_files = ['README.markdown']
  s.rdoc_options     = ["--charset=UTF-8"]

  s.description = <<-DESC

    # APND

    APND (Apple Push Notification Daemon) is a ruby library to send Apple Push
    Notifications (APNs) to iPhones.

    Apple recommends application developers create one connection to their
    upstream push notification server, rather than creating one per notification.

    APND acts as an intermediary between your application and Apple. Your
    application's notifications are queued to APND, which are then sent to
    Apple over a single connection.

    Within ruby applications, `APND::Notification` can be used to send
    notifications to a running APND instance or directly to Apple. A command
    line utility, `apnd-push`, can be used to send single notifications for
    testing purposes.
  DESC
end
