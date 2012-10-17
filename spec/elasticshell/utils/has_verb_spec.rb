require 'spec_helper'

describe HasVerb do

  before do
    @obj = Class.new { include HasVerb }.new
  end

  it "sets 'GET' as the default verb" do
    expect(@obj.verb).to eq("GET")
  end

  it "will allow setting a new verb" do
    @obj.verb = "POST"
    expect(@obj.verb).to eq("POST")
  end

  it "will not allow setting an invalid verb" do
    @obj.verb = "SUCK"
    expect(@obj.verb).to eq("GET")
  end
  
end

