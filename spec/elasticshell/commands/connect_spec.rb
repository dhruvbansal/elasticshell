require 'spec_helper'

describe Commands::Connect do

  
  before do
    @shell = Shell.new
  end

  it "should start a connection to the default servers" do
    @shell.client.should_receive(:safely_connect).with()
    expect(@shell.eval_line("connect"))
  end

  it "should start a connection to the given comma-separated servers" do
    @shell.client.should_receive(:safely_connect).with(:servers => %w[http://123.123.123.123:9200/ http://321.321.321.321:9200/])
    expect(@shell.eval_line("connect http://123.123.123.123:9200 http://321.321.321.321:9200"))
  end
  
  
end
