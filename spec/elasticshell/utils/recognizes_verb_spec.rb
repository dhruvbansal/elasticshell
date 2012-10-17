require 'spec_helper'

describe RecognizesVerb do

  before do
    @obj = Class.new { include RecognizesVerb }.new
  end

  it "can recognize an HTTP verb" do
    expect(@obj.is_http_verb?("GET")).to be_true
    expect(@obj.is_http_verb?("get")).to be_true
    expect(@obj.is_http_verb?("HEAD")).to be_true
    expect(@obj.is_http_verb?("POST")).to be_true
  end

  it "can canonicalize HTTP verbs" do
    expect(@obj.canonicalize_verb("get")).to eq("GET")
    expect(@obj.canonicalize_verb("gEt")).to eq("GET")
    expect(@obj.canonicalize_verb(:get)).to  eq("GET")
  end
  
end

