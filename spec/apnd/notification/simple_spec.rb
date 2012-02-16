require 'spec_helper'

describe APND::Notification::Simple do
  let(:hex_token) do
    "\xFE\x15\xA2}]\xF3\xC3Gx\xDE\xFB\x1FO8\x80&\\\xC5,\f\x04v\x82\";\xE5\x9F\xB6\x85\x00\xA9\xA2"
  end

  let!(:params) do
    {
      :token => 'fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2',
      :alert => 'Red Alert, Numba One!',
      :sound => :default,
      :badge => 10,
      :location => 'New York'
    }
  end

  subject do
    APND::Notification::Simple.new(params)
  end

  describe "MAXIMUM_PAYLOAD_BYTES" do
    it { APND::Notification::Simple::MAXIMUM_PAYLOAD_BYTES.should == 256 }
  end

  describe "Accessors" do
    it { should have_attr_accessor :token }
    it { should have_attr_accessor :alert }
    it { should have_attr_accessor :badge }
    it { should have_attr_accessor :sound }
    it { should have_attr_reader   :extra }
  end

  describe "#initialize with params hash" do
    [:token, :alert, :badge, :sound].each do |param|
      it "assigns params[:#{param}] to @#{param}" do
        subject.instance_variable_get("@#{param}").should == params[param]
      end
    end

    it "assigns extra params to @extra" do
      not_extras = [:token, :alert, :badge, :sound]
      extra_params = params.inject({}) do |hash, (key, val)|
        if not_extras.include?(key)
          hash
        else
          hash.merge(key => val)
        end
      end

      subject_extra = subject.instance_variable_get(:@extra)

      extra_params.each do |key, val|
        subject_extra.should have_key(key)
        subject_extra[key].should == extra_params[key]
      end

      not_extras.each do |key|
        subject.instance_variable_get(:@extra).should_not have_key(key)
      end
    end
  end

  describe "#to_bytes" do
    pending
  end

  describe "#valid?" do
    include_examples "#valid?"
  end

  context "Private methods" do
    describe "#hex_token" do
      it { subject.send(:hex_token).should == hex_token }
    end
  end

end
