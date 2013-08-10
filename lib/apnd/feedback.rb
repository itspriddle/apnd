module APND
  #
  # APND::Feedback receives feedback from Apple when notifications are
  # being rejected for a specific token. This is usually due to the user
  # uninstalling your application.
  #
  class Feedback

    class << self
      #
      # The host to receive feedback from, usually apple
      #
      attr_accessor :upstream_host

      #
      # The port to connect to upstream_host on
      #
      attr_accessor :upstream_port
    end

    #
    # Set upstream host/port to default values
    #
    self.upstream_host = APND.settings.feedback.host
    self.upstream_port = APND.settings.feedback.port.to_i

    #
    # Connect to Apple's Feedback Service and return an array of device
    # tokens that should no longer receive push notifications
    #
    def self.find_stale_devices(&block)
      feedback = self.new
      devices  = feedback.receive
      devices.each { |device| yield *device } if block_given?
      devices
    end

    #
    # Create a connection to Apple's Feedback Service
    #
    def initialize
      @apple = APND::Daemon::AppleConnection.new({
        :cert      => APND.settings.apple.cert,
        :cert_pass => APND.settings.apple.cert_pass,
        :host      => self.class.upstream_host,
        :port      => self.class.upstream_port.to_i
      })
    end

    #
    # Receive feedback from Apple and return an array of device tokens
    #
    def receive
      tokens = []
      @apple.open do |sock|
      while line = sock.read(38)
          payload = line.strip.unpack('N1n1H140')
          tokens << [payload[2].strip, Time.at(payload[0])]
        end
      end
      tokens
    end

  end
end
