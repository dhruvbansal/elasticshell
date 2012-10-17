require 'spec_helper'

describe Commands::Pwd do

  before do
    @shell = Shell.new(:output => FakeOutput.new)
  end

  it "should print the current scope" do
    @shell.eval_line("pwd")
    expect(@shell.output.read).to match(%r{/})
  end
  
end
