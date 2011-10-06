require File.dirname(__FILE__) + '/test_persistence_helper.rb'

class APNDPersistenceTest < Test::Unit::TestCase
  @@bytes = %|\000\000 \376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202\";\345\237\266\205\000\251\242\000\\{\"aps\":{\"alert\":\"Red Alert, Numba One!\",\"badge\":10,\"sound\":\"default\"},\"location\":\"New York\"}|

  context "APND Daemon" do
    setup do
      MongoMapper.config = YAML.load(ERB.new(File.read('mongo.yml')).result)
      @@env = { 'host' => 'localhost', 'port' => 27017}.merge(MongoMapper.config_for_environment('test'))

      APND.configure do |settings|
        settings.mongodb = 
          { :host => @@env['host'],
          :port => @@env['port'],
          :database => @@env['database']
        }
        settings.mongodb.connect
      end
    end

    context "Protocol" do
      setup do
        @daemon = TestPersistenceDaemon.new
        MongoMapper.database.collections.each(&:remove)
      end

      should "add valid notification to queue" do
        @daemon.receive_data(@@bytes)
        @daemon.unbind
        assert_equal 1, APND::Notification.all.count
      end

      should "receive multiple Notifications in a single packet" do
        @daemon.receive_data([@@bytes, @@bytes, @@bytes].join("\n"))
        @daemon.unbind
        assert_equal 3, APND::Notification.all.count
      end

      should "raise InvalidNotificationHeader parsing a bad packet" do
        assert_raise APND::Errors::InvalidNotificationHeader do
          APND::Notification.parse("I'm not a packet!")
        end
        assert_equal 0, APND::Notification.all.count
      end

      context "newlines" do
        should "be able to parse a notification with an embedded newline character" do
          @newline_notification = APND::Notification.new({
            # :token  => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
            :token  => '74b2a2197d7727a70f939de05a4c7fe8bd4a7d960a77ef4701a80cb7b293ee23',
            :alert  => 'Red Alert, Numba One!',
            :sound  => 'default',
            :badge  => 10,
            :custom => { 'location' => 'New York' }
          })
          @daemon.receive_data(@newline_notification.to_bytes)
          @daemon.unbind
          assert_equal 1, APND::Notification.all.count
        end
      end

    end
  end

end
