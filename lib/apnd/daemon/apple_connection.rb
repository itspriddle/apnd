require 'openssl'
require 'socket'

module APND
  #
  # Daemon::AppleConnection handles the persistent connection between
  # APND and Apple
  #
  class Daemon::AppleConnection
    attr_reader :ssl, :sock

    #
    # Setup a new connection
    #
    def initialize(params = {})
      @options = {
        :cert      => APND.settings.apple.cert,
        :cert_pass => APND.settings.apple.cert_pass,
        :host      => APND.settings.apple.host,
        :port      => APND.settings.apple.port.to_i
      }.merge(params)
    end

    #
    # Returns true if the connection to Apple is open
    #
    def connected?
      ! @ssl.nil?
    end

    #
    # Connect to Apple over SSL
    #
    def connect!
      cert         = File.read(@options[:cert])
      context      = OpenSSL::SSL::SSLContext.new
      context.key  = OpenSSL::PKey::RSA.new(cert, @options[:cert_pass])
      context.cert = OpenSSL::X509::Certificate.new(cert)

      @sock = TCPSocket.new(@options[:host], @options[:port])
      @ssl  = OpenSSL::SSL::SSLSocket.new(@sock, context)
      @ssl.sync = true
      @ssl.connect
    end

    #
    # Close connection
    #
    def disconnect!
      @ssl.close
      @sock.close
      @ssl = nil
      @sock = nil
    end

    #
    # Establishes a connection if needed and yields it
    #
    # Ex: open { |conn| conn.write('write to socket) }
    #
    def open(&block)
      unless connected?
        connect!
      end

      yield @ssl
    end

    #
    # Write to the connection socket
    #
    def write(raw)
      open { |conn| conn.write(raw) }
    end
  end
end
