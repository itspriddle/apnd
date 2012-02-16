require 'spec_helper'

describe APND::Notification do
  def should_parse(klass, string)
    APND::Notification.const_get(klass).should_receive(:parse).with(string)
    APND::Notification.parse string
  end

  describe "::parse" do
    it "parses a Simple packet" do
      should_parse :Simple, [0].pack('C')
    end

    it "parses an Enhanced packet" do
      should_parse :Enhanced, [1].pack('C')
    end

    it "parses an Enhanced packet", :pending => true do
      should_parse :Feedback, [8].pack('C')
    end
  end
end
