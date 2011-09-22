require 'rubygems'
require 'test/unit'
require 'shoulda-context'

begin
  require 'turn'
rescue LoadError
end

require 'apnd'

class TestDaemon
  include APND::Daemon::Protocol

  def initialize
    @queue   = []
    @address = [123, '10.10.10.1']
  end

  def queue
    @queue
  end

end

# Silence APND.logger in testing
def APND.logger(*args); end
