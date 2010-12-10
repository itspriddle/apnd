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
      ohai "#{@address.last}:#{@address.first} opened connection"
    end

    #
    # Called when a client connection is closed
    #
    def unbind
      ohai "#{@address.last}:#{@address.first} closed connection"
    end

    #
    # Add incoming notification(s) to the queue
    #
    def receive_data(data)
      (@buffer ||= "") << data
      @buffer.each_line do |line|
        if notification = APND::Notification.valid?(line)
          ohai "#{@address.last}:#{@address.first} added new Notification to queue"
          queue.push(notification)
        else
          ohai "#{@address.last}:#{@address.first} submitted invalid Notification"
        end
      end
    end
  end
end
