require 'spec_helper'

describe Shell do

  before do
    @shell = Shell.new(:output => FakeOutput.new)
  end

  it "should cache scopes with the same path" do
    Scopes.should_receive(:from_path).with("/foo", kind_of(Hash))
    @shell.scope_from_path("/foo")
  end

  describe "printing output" do
    
  end
  
end

