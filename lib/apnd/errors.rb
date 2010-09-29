module APND
  module Errors

    #
    # Raised if APN payload is larger than 256 bytes
    #
    class InvalidPayload < StandardError
      def initialize(message)
        super("Payload is larger than 256 bytes: '#{message}'")
      end
    end
  end
end
