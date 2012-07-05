require 'spec_helper'

describe Scopes do

  it "should be able to recognize the global scope" do
    Scopes::Global.should_receive(:new).with(kind_of(Hash))
    Scopes.from_path("/")
  end

  it "should be able to recognize an index scope" do
    Scopes::Index.should_receive(:new).with('foobar', kind_of(Hash))
    Scopes.from_path("/foobar")
  end

  it "should be able to recognize a mapping scope" do
    index = mock("Index /foobar")
    Scopes::Index.should_receive(:new).with('foobar', kind_of(Hash)).and_return(index)
    Scopes::Mapping.should_receive(:new).with(index, 'baz', kind_of(Hash))
    Scopes.from_path("/foobar/baz")
  end
  
end
