require 'uri'

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
      self.verb   = options.delete(:verb)
      self.path   = path
      self.client = options[:client]
      self.scopes = initial_scopes
    end

    def to_s
      self.path
    end

    def completion_proc
      Proc.new do |shell, prefix|
        refresh if client.connected?
        case
        when Readline.line_buffer =~ /^\s*cd\s+\S*$/
          completing_scope_path = prefix.split('/')[0..-2].join('/')
          if completing_scope_path.empty?
            completing_scope = self
          else
            completing_scope = shell.scope_from_path(File.expand_path(completing_scope_path, shell.scope.path))
          end
          completing_scope.refresh if client.connected?

          prefix_within_completing_scope = (prefix.split('/').last || '')

          # p [prefix, completing_scope.path, prefix_within_completing_scope]
          
          completing_scope.scopes.find_all do |scope|
            scope[0...prefix_within_completing_scope.length] == prefix_within_completing_scope
          end.map do |scope|
            File.join(completing_scope.path, scope).gsub(%r!^/!, '')
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
      ! self.last_refresh_at.nil?
    end

    def exists?
      false
    end

  end
  
end

  
