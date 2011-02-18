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
      APND.ohai "#{@address.last}:#{@address.first} opened connection"
    end

    #
    # Called when a client connection is closed
    #
    # Checks @buffer for any pending notifications to be
    # queued
    #
    def unbind
      @buffer.chomp.split("\n").each do |line|
        if notification = APND::Notification.valid?(line)
          APND.ohai "#{@address.last}:#{@address.first} added new Notification to queue"
          queue.push(notification)
        else
          APND.ohai "#{@address.last}:#{@address.first} submitted invalid Notification"
        end
      end
      APND.ohai "#{@address.last}:#{@address.first} closed connection"
    end

    #
    # Add incoming notification(s) to @buffer
    #
    def receive_data(data)
      APND.ohai "#{@address.last}:#{@address.first} buffering data"
      (@buffer ||= "") << data
    end
  end
end
