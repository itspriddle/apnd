require 'eventmachine'

module APND
  #
  # The APND::Daemon maintains a persistent secure connection with Apple,
  # (APND::Daemon::AppleConnection). Notifications are queued and periodically
  # writen to the AppleConnection
  #
  class Daemon
    autoload :Protocol,         'apnd/daemon/protocol'
    autoload :AppleConnection,  'apnd/daemon/apple_connection'
    autoload :ServerConnection, 'apnd/daemon/server_connection'

    #
    # Create a new Daemon and run it
    #
    def self.run!
      server = APND::Daemon.new
      server.run!
    end

    #
    # Create a connection to Apple and a new EM queue
    #
    def initialize
      @queue = EM::Queue.new
      @apple = APND::Daemon::AppleConnection.new
      @bind  = APND.settings.daemon.bind
      @port  = APND.settings.daemon.port
      @timer = APND.settings.daemon.timer
    end

    #
    # Run the daemon
    #
    def run!
      EventMachine::run do
        APND.logger "Starting APND Daemon v#{APND::Version} on #{@bind}:#{@port}"
        EventMachine::start_server(@bind, @port, APND::Daemon::ServerConnection) do |server|
          server.queue = @queue
        end

        EventMachine::PeriodicTimer.new(@timer) do
          process_notifications!
        end
      end
    end

  private

    #
    # Sends each notification in the queue upstream to Apple
    #
    def process_notifications!
      count = @queue.size
      if count > 0
        APND.logger "Queue has #{count} item#{count == 1 ? '' : 's'}"
        @apple.connect!
        count.times do
          @queue.pop do |notification|
            begin
              APND.logger "Sending notification for #{notification.token}"
              @apple.write(notification.to_bytes)
            rescue Errno::EPIPE, OpenSSL::SSL::SSLError
              APND.logger "Error, notification has been added back to the queue"
              @queue.push(notification)
              @apple.reconnect!
            rescue RuntimeError => error
              APND.logger "Error: #{error}"
            end
          end
        end
        @apple.disconnect!
      end
    end

  end
end
