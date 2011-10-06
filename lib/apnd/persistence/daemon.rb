module APND
  class Daemon
    #
    # Sends each notification in the store upstream to Apple
    #
    def process_notifications!
      pending = APND::Notification.all()
      if pending.size > 0
        APND.logger "Queue has #{pending.size} item#{pending.size == 1 ? '' : 's'}"
        @apple.connect!
        pending.each do |notification|
          begin
            APND.logger "Sending notification for #{notification.token}"
            @apple.write(notification.to_bytes)
            notification.destroy
          rescue Errno::EPIPE, OpenSSL::SSL::SSLError
            APND.logger "Error, notification will be sent next time around"
            @apple.reconnect!
          rescue RuntimeError => error
            APND.logger "Error: #{error}"
          end
        end
        @apple.disconnect!
      end
    end

    def enqueue_notification(n)
      n.save!
    end

  end
end
