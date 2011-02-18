# APND

APND (Apple Push Notification Daemon) is a ruby library to send Apple Push
Notifications to iPhones.

Apple recommends application developers create one connection to their
upstream push notification server, rather than creating one per notification.

APND acts as an intermediary between your application and Apple (see **APND
Daemon** below). Your application's notifications are queued to APND, which
are then sent to Apple over a single connection.

Within ruby applications, `APND::Notification` can be used to send
notifications to a running APND instance (see **APND Notification** below) or
directly to Apple. The command line can be used to send single notifications
for testing purposes (see **APND Client** below).


## General Usage

### APND Daemon

APND receives push notifications from your application and relays them to
Apple over a single connection as explained above. The `apnd` command line
utility is used to start APND.

    Usage:
      apnd daemon [OPTIONS] --apple-cert </path/to/cert>

    Required Arguments:
            --apple-cert      [PATH]     PATH to APN certificate from Apple

    Optional Arguments:
            --apple-host      [HOST]     Connect to Apple at HOST (default is gateway.sandbox.push.apple.com)
            --apple-port      [PORT]     Connect to Apple on PORT (default is 2195)
            --apple-cert-pass [PASSWORD] PASSWORD for APN certificate from Apple
            --daemon-port     [PORT]     Run APND on PORT (default is 22195)
            --daemon-bind     [ADDRESS]  Bind APND to ADDRESS (default is 0.0.0.0)
            --daemon-log-file [PATH]     PATH to APND log file (default is /var/log/apnd.log)
            --daemon-timer    [SECONDS]  Set APND queue refresh time to SECONDS (default is 30)
            --foreground                 Run APND in foreground without daemonizing

    Help:
            --help                       Show this message


### APND Client

APND includes a command line client which can be used to send notifications to
a running APND instance. It is only recommended to send notifications via
`apnd push` for testing purposes.

    Usage:
      apnd push [OPTIONS] --token <token>

    Required Arguments:
            --token  [TOKEN]             Set Notification's iPhone token to TOKEN

    Optional Arguments:
            --alert  [MESSAGE]           Set Notification's alert to MESSAGE
            --sound  [SOUND]             Set Notification's sound to SOUND
            --badge  [NUMBER]            Set Notification's badge number to NUMBER
            --custom [JSON]              Set Notification's custom data to JSON
            --host   [HOST]              Send Notification to HOST, usually the one running APND (default is 'localhost')
            --port   [PORT]              Send Notification on PORT (default is 22195)

    Help:
            --help                       Show this message


### APND Notification

The `APND::Notification` class can be used within your application to send
push notifications to APND.

    require 'apnd'

    # Set the host/port APND is running on
    # (not needed if you're using localhost:22195)
    # Put this in config/initializers/apnd.rb for Rails
    APND::Notification.upstream_host = 'localhost'
    APND::Notification.upstream_port = 22195


    # Initialize some notifications
    notification1 = APND::Notification.new(
      :alert  => 'Alert!',
      :token  => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :badge  => 1
    )

    notification2 = APND::Notification.new(
      :alert  => 'Red Alert!',
      :token  => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :badge  => 99
    )


    # Send multiple notifications at once to avoid overhead in
    # opening/closing the upstream socket connection each time
    #
    # *IMPORTANT!* Use sock.puts as it appends a new line. If you don't,
    # you'll only receive the first notification.

    APND::Notification.open_upstream_socket do |sock|
      sock.puts(notification1.to_bytes)
      sock.puts(notification2.to_bytes)
    end


    # Send a notification to the upstream socket immediately
    notification3 = APND::Notification.create(
      :alert  => 'Alert!',
      :token  => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :badge  => 0
    )


### APND Feedback

Apple Push Notification Service keeps a log when you attempt to deliver
a notification to a device that has removed your application. A Feedback
Service is provided which applications should periodically check to remove
from their databases.

The `APND::Feedback` class can be used within your application to retrieve
a list of device tokens that you are sending notifications to but have
removed your application.

    APND::Feedback.upstream_host = 'feedback.push.apple.com'
    APND::Feedback.upstream_port = 2196

    # Block form
    APND::Feedback.find_stale_devices do |token, removed_at|
      device = YourApp::Device.find_by_token(token)
      unless device.registered_at > removed_at
        device.push_enabled = 0
        device.save
      end
    end

    # Array form
    stale = APND::Feedback.find_stale_devices
    stale.each do |(token, removed_at)|
      device = YourApp::Device.find_by_token(token)
      unless device.registered_at > removed_at
        device.push_enabled = 0
        device.save
      end
    end


## Prerequisites

You must have a valid Apple Push Notification Certificate for your iPhone
application. Obtain your APN certificate from the iPhone Provisioning Portal
at [developer.apple.com](http://developer.apple.com/).


## Requirements

* [EventMachine](http://github.com/eventmachine/eventmachine)
* [Daemons](http://github.com/ghazel/daemons)
* [JSON](http://github.com/flori/json)

Ruby must be compiled with OpenSSL support.

Tests use [Shoulda](http://github.com/thoughtbot/shoulda), and optionally
[TURN](https://github.com/TwP/turn).


## Installation

RubyGems:

    gem install apnd

Git:

    git clone git://github.com/itspriddle/apnd.git


## Credit

APND is based on [apnserver](http://github.com/bpoweski/apnserver) and
[apn_on_rails](http://github.com/PRX/apn_on_rails). Either worked just how I
wanted, so I rolled my own using theirs as starting points. If APND doesn't
suit you, check them out instead.


## Copyright

Copyright (c) 2010-2011 Joshua Priddle. See LICENSE for details.
