require 'spec_helper'

describe APND::Notification::Enhanced do
  let!(:params) do
    {
      :token      => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :alert      => 'Red Alert, Numba One!',
      :sound      => :default,
      :badge      => 10,
      :expiry     => Time.now.to_i + 3600,
      :identifier => 'ABCD',
      :location   => 'New York'
    }
  end

  subject do
    APND::Notification::Enhanced.new(params)
  end

  its(:class) { should be < APND::Notification::Simple }

  describe "Accessors" do
    it { should have_attr_accessor :identifier }
    it { should have_attr_accessor :expiry }
  end

  describe "#initialize" do
    pending
  end

  describe "#valid?" do
    include_examples "#valid?"
    it "validates token length"
    it "validates identifier length"
  end

  describe "#to_bytes" do

  end
end
