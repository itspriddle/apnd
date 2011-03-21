require File.dirname(__FILE__) + '/test_helper.rb'

class APNDTest < Test::Unit::TestCase
  @@bytes = %|\000\000 \376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202\";\345\237\266\205\000\251\242\000\\{\"aps\":{\"alert\":\"Red Alert, Numba One!\",\"badge\":10,\"sound\":\"default\"},\"location\":\"New York\"}|

  context "APND Notification" do
    setup do
      @notification = APND::Notification.new({
        :token  => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
        :alert  => 'Red Alert, Numba One!',
        :sound  => 'default',
        :badge  => 10,
        :custom => { 'location' => 'New York' }
      })
    end

    should "allow initialization with options hash" do
      [:token, :alert, :sound, :badge, :custom].each do |key|
        assert_not_nil @notification.send(key)
      end
    end

    should "parse a raw packet" do
      notification = APND::Notification.parse(@@bytes)

      assert notification

      [:alert, :badge, :custom, :sound, :token, :hex_token, :to_bytes, :aps, :aps_json].each do |key|
        assert_equal @notification.send(key), notification.send(key)
      end
    end

    should "raise InvalidPayload if custom hash is too large" do
      assert_raise APND::Errors::InvalidPayload do
        notification = @notification.dup
        notification.custom = {
          'lorem' => "Hi! " * 200
        }
        APND::Notification.parse(notification.to_bytes)
      end
    end

    context "instances" do
      should "return a valid hex_token" do
        expected = %|\376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202";\345\237\266\205\000\251\242|
        assert_equal @notification.hex_token, expected
      end

      should "return a valid byte string" do
        assert_equal @notification.to_bytes, @@bytes
      end
    end


    
  end

  context "APND Daemon" do
    context "Protocol" do
      setup do
        @daemon = TestDaemon.new
      end

      should "add valid notification to queue" do
        @daemon.receive_data(@@bytes)
        @daemon.unbind
        assert_equal 1, @daemon.queue.size
      end

      should "receive multiple Notifications in a single packet" do
        @daemon.receive_data([@@bytes, @@bytes, @@bytes].join("\n"))
        @daemon.unbind
        assert_equal 3, @daemon.queue.size
      end

      should "raise InvalidNotificationHeader parsing a bad packet" do
        assert_raise APND::Errors::InvalidNotificationHeader do
          APND::Notification.parse("I'm not a packet!")
        end
        assert_equal 0, @daemon.queue.size
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
          assert_equal 1, @daemon.queue.size

        end
      end

    end
  end

end
