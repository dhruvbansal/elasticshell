require 'spec_helper'

describe Commands::SetVerb do

  before do
    @shell = Shell.new
  end

  it "set the shell's default verb" do
    @shell.eval_line("put")
    expect(@shell.verb).to eql("PUT")
  end

end
