require 'rspec'
require 'apnd'

RSpec::Matchers.define :have_attr_accessor do |attribute|
  match do |object|
    object.respond_to?(attribute) && object.respond_to?("#{attribute}=")
  end

  description do
    "have attr_accessor :#{attribute}"
  end
end

RSpec::Matchers.define :have_attr_reader do |attribute|
  match do |object|
    object.respond_to? attribute
  end

  description do
    "have attr_reader :#{attribute}"
  end
end

RSpec::Matchers.define :have_attr_writer do |attribute|
  match do |object|
    object.respond_to? "#{attribute}="
  end

  description do
    "have attr_writer :#{attribute}"
  end
end



  shared_examples "#valid?" do
    context "requires @token" do
      before { subject.token = nil }
      its(:valid?) { should be_false }
    end

    context "requires one @alert, @badge, or @sound" do
      context "with none set" do
        before { subject.alert = subject.badge = subject.sound = nil }
        its(:valid?) { should be_false }
      end

      context "with @alert set" do
        before { subject.badge = subject.sound = nil }
        its(:valid?) { should be_true }
      end

      context "with @badge set" do
        before { subject.alert = subject.sound = nil }
        its(:valid?) { should be_true }
      end

      context "with @sound set" do
        before { subject.alert = subject.badge = nil }
        its(:valid?) { should be_true }
      end
    end

    context "requires payload to be <= 256 bytes" do
      before { subject.alert = "Alert! " * 100 }
      its(:valid?) { should be_false }
    end
  end

