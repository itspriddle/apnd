require 'socket'

module APND
  #
  # Daemon::Protocol handles incoming APNs
  #
  class Daemon::ServerConnection < ::EventMachine::Connection

    include APND::Daemon::Protocol

    #
    # Queue should be the EventMachine queue, see APND::Daemon
    #
    attr_accessor :queue

  end
end
