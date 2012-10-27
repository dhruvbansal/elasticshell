require 'spec_helper'

describe Commands::Cd do

  before do
    @shell  = Shell.new(:output => FakeOutput.new)
  end
  
  it "should change scope when given an argument" do
    expect(@shell.eval_line("cd /foo").path).to eq("/foo")
  end

  it "should change to the global scope when given no argument" do
    expect(@shell.eval_line("cd /foo").eval_line("cd").path).to eq("/")
  end

  it "should properly interpret relative path names" do
    expect(@shell.eval_line("cd /foo").eval_line("cd ..").path).to eq("/")
    expect(@shell.eval_line("cd /foo/bar").eval_line("cd ..").path).to eq("/foo")
    expect(@shell.eval_line("cd /foo/bar").eval_line("cd ../baz").path).to eq("/foo/baz")
  end
  
end
