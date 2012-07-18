require 'uri'

require 'elasticshell/utils/has_verb'

module Elasticshell
  
  module Scopes

    autoload :Global,  'elasticshell/scopes/global'
    autoload :Cluster, 'elasticshell/scopes/cluster'
    autoload :Nodes,   'elasticshell/scopes/nodes'
    autoload :Index,   'elasticshell/scopes/index'
    autoload :Mapping, 'elasticshell/scopes/mapping'

    def self.global options={}
      Global.new(options)
    end

    def self.cluster options={}
      Cluster.new(options)
    end

    def self.nodes options={}
      Nodes.new(options)
    end

    def self.index name, options={}
      Index.new(name, options)
    end

    def self.mapping index_name, mapping_name, options={}
      Mapping.new(index(index_name, options), mapping_name, options)
    end

    def self.from_path path, options={}
      segments = path.to_s.strip.gsub(%r!^/!,'').gsub(%r!/$!,'').split('/')
      case
      when segments.length == 0
        global(options)
      when segments.length == 1 && segments.first == '_cluster'
        cluster(options)
      when segments.length == 1 && segments.first == '_nodes'
        nodes(options)
      when segments.length == 1
        index(segments.first, options)
      when segments.length == 2
        mapping(segments[0], segments[1], options)
      else
        raise ArgumentError.new("'#{path}' does not define a valid path for a scope.")
      end
    end
  end

  class Scope

    include Elasticshell::HasVerb

    attr_accessor :path, :client, :last_refresh_at, :scopes

    def self.requests
      @requests ||= {}
    end
    
    def initialize path, options
      self.verb   = (options.delete(:verb) || 'GET')
      self.path   = path
      self.client = options[:client]
      self.scopes = initial_scopes
    end

    def to_s
      self.path
    end

    def completion_proc
      Proc.new do |prefix|
        refresh if client.connected?
        case
        when Readline.line_buffer =~ /^\s*cd\s+\S*$/
          # FIXME allow completion when providing a nested prefix like
          # 'foo/ba' from within scope '/' by completing with respect
          # to scope 'foo' instead of only scope '/' as done here.
          scopes.find_all do |scope|
            scope[0...prefix.length] == prefix
          end
        when Readline.line_buffer =~ /^\s*\S*$/
          request_names.find_all do |request_name|
            request_name[0...prefix.length] == prefix
          end
        else
          Dir[prefix + '*']
        end
      end
    end

    def requests
      self.class.requests[verb] || {}
    end

    def request_names
      requests.keys
    end
    
    def refresh
      refresh! unless refreshed?
    end

    def refresh!
      reset!
      fetch_scopes
      self.last_refresh_at = Time.now
      true
    end

    def fetch_scopes
    end

    def initial_scopes
      []
    end

    def reset!
      self.scopes = initial_scopes
      true
    end

    def refreshed?
      self.last_refresh_at
    end

    def exists?
      false
    end

    def help
      [].tap do |msg|
        msg << "Requests specific to the scope '#{path}':"
        msg << ''
        requests.each_pair do |request_name, description|
          msg << '  ' + request_name
          msg << ('    ' + description)
          msg << ''
        end
      end.join("\n")
    end

  end
  
end

  
