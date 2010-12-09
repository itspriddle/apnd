require File.dirname(__FILE__) + '/test_helper.rb'

context "APND" do
  setup do
    @bytes = %|\000\000 \376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202";\345\237\266\205\000\251\242\000;{"aps":{"sound":"default","alert":"Red Alert, Numba One!"}}|
    @notification = APND::Notification.new({
      :token => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :alert => 'Red Alert, Numba One!',
      :sound => 'default'
    })
  end

  test "Notification returns a valid hex_token" do
    expected = %|\376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202";\345\237\266\205\000\251\242|
    assert_equal @notification.hex_token, expected
  end

  test "Notification returns a valid byte string for Apple" do
    assert_equal @notification.to_bytes, @bytes
  end

  test "Notification.parse returns a Notification when given a valid string" do
    notification = APND::Notification.parse(@bytes)

    assert notification

    [:alert, :badge, :custom, :sound, :token, :hex_token, :to_bytes, :aps, :aps_json].each do |key|
      assert_equal @notification.send(key), notification.send(key)
    end

    assert ! APND::Notification.parse("I'm not a packet!")
  end

  test "Packet can contain multiple Notifications" do
    notifications = [@bytes, @bytes, @bytes].join("\n")
    notifications.each_line do |line|
      assert APND::Notification.valid?(line)
    end
  end

end
