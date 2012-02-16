require 'spec_helper'

describe APND do
  describe "::Version" do
    it "has a valid version" do
      APND::Version.should match /\d+\.\d+\.\d+/
    end
  end
end
