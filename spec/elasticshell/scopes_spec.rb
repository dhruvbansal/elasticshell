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

describe Scope do

  before do
    @klass = Class.new(Scope) do
      def self.requests
        {
          "GET" => {
            '_a'  => "Request a",
          },
          "POST" => {
            '_b'  => "Request b",
          }
        }
      end

      def initial_scopes
        ["joe", "mary"]
      end

      def fetch_scopes
        self.scopes << "sue"
      end
      
    end
    @scope = @klass.new("/path/seg", {})
  end

  it "should restrict available requests to those matching its current verb" do
    expect(@scope.requests).to include("_a")
    @scope.verb = "POST"
    expect(@scope.requests).to include("_b")
  end

  it "should reset and fetch new scopes when refreshing, but only once" do
    @scope.should_receive(:reset!)
    @scope.should_receive(:fetch_scopes)
    3.times { @scope.refresh }
  end

end

  
