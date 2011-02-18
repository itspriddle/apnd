require 'json'

module APND
  autoload :Version,      'apnd/version'
  autoload :Errors,       'apnd/errors'
  autoload :Settings,     'apnd/settings'
  autoload :Daemon,       'apnd/daemon'
  autoload :Notification, 'apnd/notification'
  autoload :Feedback,     'apnd/feedback'

  #
  # Returns APND::Settings
  #
  def self.settings
    @@settings ||= Settings.new
  end

  #
  # Yields APND::Settings
  #
  def self.configure
    yield settings
  end

  #
  # Write message to stdout with date
  #
  def self.logger(message) #:nodoc:
    puts "[%s] %s" % [Time.now.strftime("%Y-%m-%d %H:%M:%S"), message]
  end

end
