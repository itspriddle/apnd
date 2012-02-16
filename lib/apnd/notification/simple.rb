require 'json'

module APND
  module Notification
    # See http://bit.ly/iCdRmd for info about the Apple Push Notification Service
    class Simple
      # The maximum number of bytes allowed for a notification.
      MAXIMUM_PAYLOAD_BYTES = 256

      # Public: Get or set the iOS Device token.
      attr_accessor :token

      # Public: Get or set the alert text.
      attr_accessor :alert

      # Public: Get or set the alert badge count.
      attr_accessor :badge

      # Public: Get or set the sound.
      attr_accessor :sound

      # Public: Get extra data in the notification. This includes everything
      # other than the attr_accessors listed above.
      attr_reader :extra

      # Public: Parse a binary string into a new Notification.
      #
      # string - Binary content representing the notification.
      #
      # Example:
      #
      #     n = Notification::Simple.parse "RAW_PACKET"
      #
      # Returns a new Notification object if the string was a valid
      # notification, otherwise returns nil.
      def self.parse(string)
        command      = string.slice!(0, 1).unpack('C').first
        token_length = string.slice!(0, 2).unpack('n').first
        token        = string.slice!(0, token_length).unpack('H*').first
        json_length  = string.slice!(0, 2).unpack('n').first
        json         = string.slice!(0, json_length)

        return unless command == 0

        payload = JSON.parse(json).deep_symbolize

        params = payload.delete(:aps)
        params.merge!(:token => token)
        params.merge!(payload) unless payload.empty?

        self.new(params)
      end

      # Initializes a new Simple notification object.
      #
      # params - An optional Hash containing data for the notification. The
      #          following keys are special, and are set as instance variables:
      #
      #          :token - The iOS device token as a hex string.
      #          :alert - String alert text to be sent to the user.
      #          :badge - The Integer badge count. Use 0 to clear.
      #          :sound - The String sound file to use. The file must be
      #                   present in your app.
      #
      #          Any remaining parameters are set to @extra.
      def initialize(params = {})
        params = params.dup.deep_symbolize
        @token = params.delete :token
        @alert = params.delete :alert
        @badge = params.delete :badge
        @sound = params.delete :sound
        @extra = params
      end

      # Public: Validate this Simple notification.
      #
      # A valid Simple notification:
      #   * must have a valid token
      #   * must have at lease one of alert, badge, or sound
      #   * must not exceed 256 bytes
      #
      # Returns true if the notification is valid, false if not.
      def valid?
        token && [alert, sound, badge].any? && to_bytes.bytesize <= 256
      end

      # Public: Create a Simple notification packet. This packet is suitable to
      # be sent to either Apple or an APND Daemon.
      #
      # Simple notifications are binary content made up of the following:
      #
      #   1  byte: command (always 0, this indicates a simple notification)
      #   2 bytes: device token length (big endian, network order), usually [0, 32]
      #  32 bytes: device token
      #   2 bytes: payload length (the length of the APS hash and any additional content as JSON)
      # 218 bytes: the notification payload as JSON. Cannot exceed 218 bytes
      #
      # Returns a String.
      def to_bytes
        [0, hex_token.bytesize, hex_token, json_payload.bytesize, json_payload].pack('CnA*nA*')
      end

      # Public: The Notification payload as a Hash.
      #
      # Returns a Hash.
      def payload
        content = {}.tap do |a|
          a[:alert] = alert if alert
          a[:badge] = badge if badge
          a[:sound] = sound if sound
        end
        aps = { :aps => content }
        aps.merge!(extra) unless extra.empty?
        aps
      end

      # Public: The Notification payload parsed as JSON.
      #
      # Returns a String.
      def json_payload
        payload.to_json
      end

      private

      def hex_token
        [token].pack('H*')
      end
    end # end class APND::Notification::Simple
  end
end
