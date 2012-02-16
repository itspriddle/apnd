require 'apnd/notification/simple'
require 'apnd/notification/enhanced'

module APND
  module Notification
    # Public: Parses a raw notification. This can be used to determine if a
    # binary string is a simple notification, enhanced notification, or
    # feedback from Apple.
    #
    # string - Binary content representing the notification.
    #
    # Returns a new Simple/Enhanced/Feedback Notification object depending on
    # the string.
    def self.parse(string)
      case string[0, 1].unpack('C').first
      when 0; Simple.parse string
      when 1; Enhanced.parse string
      else
        raise "Invalid notification!"
      end
    end
  end
end
