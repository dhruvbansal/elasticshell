require 'spec_helper'

describe Commands::Ls do

  before do
    @shell = Shell.new(:output => FakeOutput.new)
    @shell.stub!(:connected?).and_return(true)
  end

  it "should provide a listing of the current scope's contents" do
    @shell.scope.should_receive(:refresh!)
    @shell.scope.stub!(:scopes).and_return(["snap", "crackle"])
    @shell.eval_line("ls")
    expect(@shell.output.read).to match(/crackle.+snap/)
  end

  it "should provide a long listing of the current scope's contents" do
    @shell.scope.should_receive(:refresh!)
    @shell.scope.stub!(:scopes).and_return(["snap", "crackle"])
    @shell.eval_line("ll")
    expect(@shell.output.read).to match(/^s.+crackle.*$\ns.+snap.*$/)
  end
  
end
