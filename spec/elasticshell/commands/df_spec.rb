require 'spec_helper'

describe Commands::Df do

  before do
    @shell  = Shell.new(:output => FakeOutput.new)
  end

  it "should produce a summary of disk usage by index" do
    @global = mock("Global scope")
    @shell.stub!(:connected?).and_return(true)
    @shell.stub!(:scope_from_path).with("/").and_return(@global)
    @global.stub!(:status).and_return({"indices"=>{"foo"=>{"index"=>{"size"=>"986b", "size_in_bytes"=>"986"}}}})
    @shell.eval_line("df")
    expect(@shell.output.read).to match(/986.+986b.+foo/)
  end
  
end
