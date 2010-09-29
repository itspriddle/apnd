module APND
  #
  # Settings for APND
  #
  class Settings

    #
    # Settings for APND::Daemon::AppleConnection
    #
    class AppleConnection

      #
      # Host used to connect to Apple
      #
      #   Development: gateway.sandbox.push.apple.com
      #   Production: gateway.push.apple.com
      #
      attr_accessor :host

      #
      # Port used to connect to Apple
      #
      attr_accessor :port

      #
      # Path to APN cert for your application
      #
      attr_accessor :cert

      #
      # Password for APN cert, optional
      #
      attr_accessor :cert_pass

      def initialize
        @host = 'gateway.sandbox.push.apple.com'
        @port = 2195
      end
    end

    #
    # Settings for APND::Daemon
    #
    class Daemon

      #
      # IP to bind APND::Daemon to
      #
      #   Default: '0.0.0.0'
      #
      attr_accessor :bind

      #
      # Port APND::Daemon will run on
      #
      #   Default: 22195
      #
      attr_accessor :port

      #
      # Path to APND::Daemon log
      #
      #   Default: /var/log/apnd.log
      #
      attr_accessor :log_file

      #
      # Interval (in seconds) the queue will be processed
      #
      #   Default: 30
      #
      attr_accessor :timer

      def initialize
        @timer    = 30
        @bind     = '0.0.0.0'
        @port     = 22195
        @log_file = '/var/log/apnd.log'
      end
    end

    #
    # Settings for APND::Notification
    #
    class Notification

      #
      # Host to send notification to, usually the one running APND::Daemon
      #
      #   Default: localhost
      #
      attr_accessor :host

      #
      # Port to send notifications to
      #
      #   Default: 22195
      #
      attr_accessor :port

      def initialize
        @host = 'localhost'
        @port = 22195
      end
    end

    #
    # Returns the AppleConnection settings
    #
    def apple
      @apple ||= APND::Settings::AppleConnection.new
    end

    #
    # Returns the Daemon settings
    #
    def daemon
      @daemon ||= APND::Settings::Daemon.new
    end

    #
    # Returns the Notification settings
    #
    def notification
      @notification ||= APND::Settings::Notification.new
    end
  end
end
