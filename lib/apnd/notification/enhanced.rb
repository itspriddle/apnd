module APND
  module Notification
    class Enhanced < Simple
      attr_accessor :identifier
      attr_accessor :expiry

      # Public: Parse a binary string into a new Enhanced notification.
      #
      # string - Binary content representing the notification.
      #
      # Example:
      #
      #     n = Notification::Enhanced.parse "RAW_PACKET"
      #
      # Returns a new Enhanced notification object if the string was a valid
      # notification, otherwise returns nil.
      def self.parse(string)
        command      = string.slice!(0, 1).unpack('C').first
        identifier   = string.slice!(0, 4).unpack('A4').first
        expiry       = string.slice!(0, 4).unpack('N').first
        token_length = string.slice!(0, 2).unpack('n').first
        token        = string.slice!(0, token_length).unpack('H*').first
        json_length  = string.slice!(0, 2).unpack('n').first
        json         = string.slice!(0, json_length)

        return unless command == 1

        payload = JSON.parse(json).deep_symbolize

        params = payload.delete(:aps)
        params.merge!(
          :token      => token,
          :identifier => identifier,
          :expiry     => expiry
        )
        params.merge!(payload) unless payload.empty?

        self.new(params)
      end

      # Initializes a new Enhanced notification object.
      #
      # params - An optional Hash containing data for the notification. The
      #          following keys are special, and are set as instance variables:
      #
      #          :token      - The iOS device token as a hex string.
      #          :alert      - String alert text to be sent to the user.
      #          :badge      - The Integer badge count. Use 0 to clear.
      #          :sound      - The String sound file to use. The file must be
      #                        present in your app.
      #          :identifier - Arbitrary value used to identify this
      #                        notification. Apple will send this identifier
      #                        with an error response if they cannot process
      #                        a notification.
      #
      #          Any remaining parameters are set to @extra.
      def initialize(params = {})
        super

        params      = @extra.dup.deep_symbolize
        @identifier = params.delete :identifier
        @expiry     = params.delete :expiry
        @extra      = params.dup
      end

      # Public: Validate this Enhanced notification.
      #
      # A valid Enhanced notification:
      #   * must have a valid expiry
      #   * must have a valid identifier
      #   * must have a valid token
      #   * must have at lease one of alert, badge, or sound
      #   * must not exceed 256 bytes
      #
      # Returns true if the notification is valid, false if not.
      def valid?
        valid_expiry? && valid_identifier? && super
      end

      # Public: Create an Enhanced notification packet. This packet is
      # suitable to be sent to either Apple or an APND Daemon.
      #
      # Enhanced notifications are binary content made up of the following
      #
      #   1  byte: command (always 1, this indicates an enhanced notification)
      #   4 bytes: identifier for this notification (arbitrary value returned if errors occur)
      #   4 bytes: expiry as UNIX timestmap (big endian, network order)
      #   2 bytes: device token length (big endian, network order), usually [0, 32]
      #  32 bytes: device token
      #   2 bytes: payload length (the length of the APS hash and any additional content as JSON)
      # 211 bytes: the notification payload as JSON. Cannot exceed 211 bytes
      #
      # Returns a string in binary format.
      def to_bytes
        [1, identifier, expiry, hex_token.bytesize, hex_token, json_payload.bytesize, json_payload].pack('CA4NnA*nA*')
      end

      private

      # Private: Validate expiry.
      #
      # A valid expiry:
      #   * must be present
      #   * must be able to convert it into a Time object
      #   * must be in the future
      #   * must be 4 bytes when converted to big endian
      #
      # Returns true if the expiry is valid, false if not.
      def valid_expiry?
        expiry && Time.at(expiry) > Time.now && [expiry].pack('N').bytesize == 4
      rescue TypeError
        false
      end

      # Private: Validate identifier.
      #
      # A valid identifier:
      #   * must be present
      #   * must be between 1 and 4 bytes
      #
      # Returns true if the identifier is valid, false if not.
      def valid_identifier?
        identifier && identifier.bytesize >= 1 && identifier.bytesize <= 4
      end
    end # end class Enhanced
  end
end
