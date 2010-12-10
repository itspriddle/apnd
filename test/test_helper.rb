require 'rubygems'
require 'test/unit'
require 'shoulda'

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

# Silence ohai in testing
def ohai(*args); end
