require 'spec_helper'

describe Client do

  before do
    @client = Client.new
  end

  describe "before connecting" do

    it "should not be connected on initialization" do
      expect(@client.connected?).to be_false
    end
    
    it "should raise an error when attempting to make a request before connecting" do
      expect { @client.request("GET") }.to raise_error(ClientError)
    end
  end

  describe "when connected" do

    before do
      @client.stub!(:connected?).and_return(true)
      @client.stub!(:log_request)
      @client.stub!(:perform_request)
      @verb   = "GET"
      @params = {:op => "/foobar"}
    end

    it "should log all requests by default" do
      @client.should_receive(:log_request).with(@verb, @params, {})
      @client.request(@verb, @params)
    end

    it "should allow skipping request logging when asked" do
      @client.should_not_receive(:log_request)
      @client.request(@verb, @params, {:log => false})
    end
    
    it "wrap client library errors in its own custom error class" do
      @client.stub!(:perform_request).and_raise(ElasticSearch::RequestError)
      expect { @client.request(@verb, @params) }.to raise_error(ClientError)
    end

    it "should return safely from a client library error if asked" do
      @client.stub!(:perform_request).and_raise(ElasticSearch::RequestError)
      expect(@client.request(@verb, @params, {:safely => true, :return => 3})).to eq(3)
      expect(@client.safely(@verb, @params)).to be_nil
    end

    
    
  end

end
