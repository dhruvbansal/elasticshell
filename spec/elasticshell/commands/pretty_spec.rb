require 'spec_helper'

describe Commands::Pretty do

  before do
    @shell = Shell.new
  end

  it "should set the shell to pretty when it's not pretty" do
    @shell.eval_line("pretty")
    expect(@shell.pretty?).to be_true
  end

  it "should set the shell to pretty when it's not pretty" do
    @shell.eval_line("pretty").eval_line("pretty")
    expect(@shell.pretty?).to be_false
  end
  
end
