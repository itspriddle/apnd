module APND
  #
  # Daemon::Protocol handles incoming APNs
  #
  class Daemon::Protocol < ::EventMachine::Connection
    attr_accessor :queue

    def post_init
      @address = Socket.unpack_sockaddr_in(self.get_peername)
      ohai "#{@address.last}:#{@address.first} opened connection"
    end

    def unbind
      ohai "#{@address.last}:#{@address.first} closed connection"
    end

    #
    # Add incoming notification to the queue if it is valid
    #
    def receive_data(data)
      (@buffer ||= "") << data
      if notification = APND::Notification.valid?(@buffer)
        ohai "#{@address.last}:#{@address.first} added new Notification to queue"
        queue.push(notification)
      else
        ohai "#{@address.last}:#{@address.first} submitted invalid Notification"
      end
    end
  end
end
