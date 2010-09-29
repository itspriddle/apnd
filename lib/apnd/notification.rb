require 'socket'

module APND
  #
  # APND::Notification is the base class for creating new push notifications.
  #
  class Notification

    class << self
      attr_accessor :upstream_host
      attr_accessor :upstream_port
    end

    self.upstream_host = APND.settings.notification.host
    self.upstream_port = APND.settings.notification.port.to_i

    attr_accessor :token, :alert, :badge, :sound, :custom

    #
    # Create a new APN
    #
    def self.create(params = {}, push = true)
      notification = Notification.new(params)
      notification.push! if push
      notification
    end

    #
    # Try to create a new Notification from raw data
    # Used by Daemon::Protocol to validate incoming data
    #
    def self.valid?(data)
      parse(data)
    rescue
      false
    end

    #
    # Parse raw data into a new Notification
    #
    def self.parse(data)
      buffer = data.dup
      notification = Notification.new

      header = buffer.slice!(0, 3).unpack('ccc')

      if header[0] != 0
        raise RuntimeError, "Invalid Notification header: #{header.inspect}"
      end

      notification.token = buffer.slice!(0, 32).unpack('H*').first

      json_length = buffer.slice!(0, 2).unpack('CC')

      json = buffer.slice!(0, json_length.last)

      payload = JSON.parse(json)

      %w[alert sound badge].each do |key|
        if payload['aps'] && payload['aps'][key]
          notification.send("#{key}=", payload['aps'][key])
        end
      end

      payload.delete('aps')

      unless payload.empty?
        notification.custom = payload
      end

      notification
    end

    #
    # Create a new Notification object from a hash
    #
    def initialize(params = {})
      @token  = params[:token]
      @alert  = params[:alert]
      @badge  = params[:badge]
      @sound  = params[:sound] || 'default'
      @custom = params[:custom]
    end

    #
    # Token in hex format
    #
    def hex_token
      [self.token.delete(' ')].pack('H*')
    end

    #
    # aps hash sent to Apple
    #
    def aps
      aps = {}
      aps['alert'] = self.alert      if self.alert
      aps['badge'] = self.badge.to_i if self.badge
      aps['sound'] = self.sound      if self.sound

      output = { 'aps' => aps }

      if self.custom
        self.custom.each do |key, value|
          output[key.to_s] = value
        end
      end
      output
    end

    #
    # Pushes notification to upstream host:port (default is localhost:22195)
    #
    def push!
      socket = TCPSocket.new(self.class.upstream_host, self.class.upstream_port)
      socket.write(to_bytes)
      socket.close
    end

    #
    # Returns the Notification's aps hash as json
    #
    def payload
      return @payload if @payload
      json = aps.to_json
      raise APND::InvalidPayload.new(json) if json.size > 256
      @payload = json
    end

    #
    # Format the notification as a string for submission
    # to Apple
    #
    def to_bytes
      @bytes ||= "\0\0 %s\0%s%s" % [hex_token, payload.length.chr, payload]
    end

  end
end
