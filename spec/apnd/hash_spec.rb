require 'spec_helper'

describe "APND hash" do
  let :test_hash do
    { 'one' => { 'two' => { 'three' => :three } } }
  end

  subject do
    test_hash
  end

  it "symbolizes keys recursively" do
    subject.deep_symbolize.should ==
      { :one => { :two => { :three => :three } } }
  end

  it "does not mutate the original hash" do
    subject.deep_symbolize.should_not eq(test_hash)
  end
end
