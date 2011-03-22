require 'socket'

module APND
  #
  # Daemon::Protocol handles incoming APNs
  #
  module Daemon::Protocol

    #
    # Called when a client connection is opened
    #
    def post_init
      @address = ::Socket.unpack_sockaddr_in(self.get_peername)
      APND.logger "#{@address.last}:#{@address.first} opened connection"
    end

    #
    # Called when a client connection is closed
    #
    # Checks @buffer for any pending notifications to be
    # queued
    #
    def unbind
      # totally broken.
      @buffer.chomp!
      while(@buffer.length > 0) do
        # 3 bytes for header
        # 32 bytes for token
        # 2 bytes for json length
        
        # taking the last is acceptable because we know it's never
        # longer than 256 bytes from the apple documentation.
        json_length = @buffer.slice(35,37).unpack('CC').last
        chunk = @buffer.slice!(0,json_length + 3 + 32 + 2)
        if notification = APND::Notification.valid?(chunk)
          APND.logger "#{@address.last}:#{@address.first} added new Notification to queue"
          queue.push(notification)
        else
          APND.logger "#{@address.last}:#{@address.first} submitted invalid Notification"
        end
        @buffer.strip!
      end
      APND.logger "#{@address.last}:#{@address.first} closed connection"
    end

    #
    # Add incoming notification(s) to @buffer
    #
    def receive_data(data)
      APND.logger "#{@address.last}:#{@address.first} buffering data"
      (@buffer ||= "") << data
    end
  end
end
