module APND
  class Settings

    #
    # Settings for APND::MongoDB if you want persistence
    #
    class MongoDB
      attr_accessor :host
      attr_accessor :port
      attr_accessor :database

      def initialize
        @host = 'localhost'
        @port = 27017
        @database = nil
      end

      def connect
        MongoMapper.connection = Mongo::Connection.new(@host, @port)
        MongoMapper.database = @database
      end
    end

    #
    # Returns the MongoDB settings
    #
    def mongodb
      @mongodb ||= APND::Settings::MongoDB.new
    end

    #
    # Mass assign MongoDB settings
    #
    def mongodb=(options = {})
      if options.respond_to?(:keys)
        mongodb.port = options[:port] if options[:port]
        mongodb.host = options[:host] if options[:host]
        mongodb.database = options[:database] if options[:database]
      end
    end
  end
end
