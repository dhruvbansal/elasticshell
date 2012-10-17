require 'spec_helper'

describe Commands::Blank do

  before do
    @shell = Shell.new
  end

  it "should do nothing" do
    @shell.eval_line("")
    expect(@shell.line).to eq(1)
  end
  
end
