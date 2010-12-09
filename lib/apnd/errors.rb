module APND
  module Errors #:nodoc: all

    #
    # Raised if APN payload is larger than 256 bytes
    #
    class InvalidPayload < StandardError
      def initialize(message)
        super("Payload is larger than 256 bytes: '#{message}'")
      end
    end

    #
    # Raised when parsing a Notification with an invalid header
    #
    class InvalidNotificationHeader < StandardError
      def initialize(header)
        super("Invalid Notification header: #{header.inspect}")
      end
    end
  end
end
