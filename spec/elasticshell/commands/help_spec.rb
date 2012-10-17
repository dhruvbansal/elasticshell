require 'spec_helper'

describe Commands::Help do

  before do
    @shell  = Shell.new(:output => FakeOutput.new)
  end

  it "should output some help text" do
    @shell.eval_line("help")
    expect(@shell.line).to eq(1)
  end

  it "should output some extra help text when asked" do
    @shell.eval_line("help")
    help = @shell.output.read.size
    @shell.eval_line("help help")
    expect(@shell.output.read.size).to be > help
  end
  
end
