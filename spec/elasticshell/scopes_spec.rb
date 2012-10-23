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
            '_a1' => "Request a1",
            '_a2' => "Request a2",
            'foo' => "Request foo"
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
        self.scopes.concat(["sue", "mark"])
      end
      
    end
    @scope = @klass.new("/path/seg", {})
  end

  it "should restrict available requests to those matching its current verb" do
    expect(@scope.requests).to include("_a1", "_a2")
    @scope.verb = "POST"
    expect(@scope.requests).to include("_b")
  end

  it "should reset and fetch new scopes when refreshing, but only once" do
    @scope.should_receive(:reset!)
    @scope.should_receive(:fetch_scopes)
    3.times { @scope.refresh }
  end

  it "should suggest matches against requests" do
    expect(@scope.requests_matching('_a')).to eql(['_a1', '_a2'])
    expect(@scope.requests_matching('f')).to  eql(['foo'])
    expect(@scope.requests_matching('s')).to  be_empty
  end

  it "should suggest matches against scopes" do
    expect(@scope.scopes_matching('j')).to eql(['/path/seg/joe/'])
    expect(@scope.scopes_matching('m')).to eql(['/path/seg/mary/'])
  end
  
  [
   %w[ /           /                 _   ],
   %w[ /foo        /                 foo ],
   %w[ /foo/       /foo              _   ],
   %w[ /foo/bar    /foo              bar ],
   %w[ /foo/bar/   /foo/bar          _   ],
   %w[ /foo/bar/ba /foo/bar          ba  ],
   %w[ _           /path/seg/        _   ],
   %w[ foo         /path/seg/        foo ],
   %w[ foo/        /path/seg/foo     _   ],
   %w[ foo/bar     /path/seg/foo     bar ],
   %w[ foo/bar/    /path/seg/foo/bar _   ],
   %w[ foo/bar/ba  /path/seg/foo/bar ba  ]
  ].each do |prefix, completing_scope_path, prefix_within_completing_scope|
    prefix                         = '' if prefix                         == '_'
    prefix_within_completing_scope = '' if prefix_within_completing_scope == '_'
    it "should properly parse the cd-prefix '#{prefix}' into a completion of the scope-prefix '#{prefix_within_completing_scope}' within the scope '#{completing_scope_path}'" do
      expect(@scope.completing_scope_path_and_prefix(prefix)).to eql([completing_scope_path, prefix_within_completing_scope])
    end
  end

  

end

  
