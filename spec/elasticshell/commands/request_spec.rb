require 'spec_helper'

describe Commands::Request do

  before do
    @shell  = Shell.new(:output => FakeOutput.new, :input => FakeOutput.new )
    @shell.stub!(:connected?).and_return(true)
  end

  it "should recognize a simple request" do
    @shell.client.should_receive(:safely).with("GET", { :op => "_simple" }, kind_of(Hash), "").and_return('{}')
    @shell.eval_line("_simple")
  end

  it "should recognize a simple request with a different verb" do
    @shell.client.should_receive(:safely).with("POST", { :op => "_simple" }, kind_of(Hash), "").and_return('{}')
    @shell.eval_line("POST _simple")
  end

  it "should recognize a request with an absolute path" do
    @shell.client.should_receive(:safely).with("GET", { :op => "some/thing" }, kind_of(Hash), "").and_return('{}')
    @shell.eval_line("/some/thing")
  end

  it "should recognize a request with a query string" do
    @shell.client.should_receive(:safely).with("GET", { :op => "_simple" }, {"foo" => "bar", "baz" => "booz what", :log => true}, "").and_return('{}')
    @shell.eval_line("_simple?foo=bar&baz=booz+what")
  end

  it "should recognize a request with an inline body" do
    @shell.client.should_receive(:safely).with("POST", { :op => "_simple" }, kind_of(Hash), "{}").and_return('{}')
    @shell.eval_line("POST _simple {}")
  end

  it "should recognize a request with a body read from a local file" do
    File.should_receive(:exist?).with("/some/file.json").and_return(true)
    File.should_receive(:read).with("/some/file.json").and_return("{}")
    @shell.client.should_receive(:safely).with("GET", { :op => "_simple" }, kind_of(Hash), "{}").and_return('{}')
    @shell.eval_line("_simple /some/file.json")
  end

  it "should recognize a request with a body read from STDIN" do
    @shell.input_stream.stub!(:gets).and_return("{}")
    @shell.client.should_receive(:safely).with("GET", { :op => "_simple" }, kind_of(Hash), "{}").and_return('{}')
    @shell.eval_line("_simple -")
  end

  it "should be able to pipe the output of a request to Ruby inline" do
    @shell.client.should_receive(:safely).with("GET", { :op => "_simple" }, kind_of(Hash), "").and_return('{}')
    @shell.eval_line("_simple | response")
  end

  it "should be able to pipe the output of a request to a RIPL session" do
    @shell.client.should_receive(:safely).with("GET", { :op => "_simple" }, kind_of(Hash), "").and_return('{}')
    require 'ripl'
    Ripl.should_receive(:start)
    @shell.eval_line("_simple |")
  end
  
end
