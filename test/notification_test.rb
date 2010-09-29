require File.dirname(__FILE__) + '/test_helper.rb'

context "APND Notification" do
  setup do
    @notification = APND::Notification.new({
      :token => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :alert => 'Red Alert, Numba One!'
    })
  end

  test "returns a properly formatted hex_token" do
    expected = %|\376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202";\345\237\266\205\000\251\242|
    assert_equal @notification.hex_token, expected
  end

  test "returns a properly formatted byte string for Apple" do
    expected = %|\000\000 \376\025\242}]\363\303Gx\336\373\037O8\200&\\\305,\f\004v\202";\345\237\266\205\000\251\242\000;{"aps":{"sound":"default","alert":"Red Alert, Numba One!"}}|
    assert_equal @notification.to_bytes, expected
  end
end
