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
          # User has typed 'cd' so we should be completing scopes only
          completing_scope_path, prefix_within_completing_scope = completing_scope_path_and_prefix(prefix)
          completing_scope = shell.scope_from_path(File.expand_path(completing_scope_path, shell.scope.path))
          completing_scope.refresh if client.connected?
          completing_scope.scopes_matching(prefix_within_completing_scope)
        when Readline.line_buffer =~ /^\s*\S*$/
          # User has started but not completed the first word in the
          # line so it must be a request available in the current
          # scope.
          requests_matching(prefix)
        when Readline.line_buffer =~ />.*$/
          # User has started to complete the name of a filesystem path
          # to redirect output to.
          Dir[prefix + '*']
        else
          # The user has finished the first word on the line so we try
          # to match to a filesystem path.
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

    def requests_matching prefix
      if prefix.empty?
        request_names.sort
      else
        request_names.find_all { |name| name[0...prefix.length] == prefix }.sort
      end
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

    def completing_scope_path_and_prefix prefix
      if prefix =~ %r!^/!
        if prefix =~ %r!/$!
          index = -1
          prefix_within_completing_scope = ''
        else
          index = -2
        end
        completing_scope_path            = prefix.split('/')[0..index].join('/')
        completing_scope_path            = '/' if completing_scope_path.empty?
        prefix_within_completing_scope ||= (prefix.split('/').last || '')
      else
        if prefix =~ %r!/$!
          index = -1
          prefix_within_completing_scope = ''
        else
          index = -2
        end
        completing_scope_path            = File.join(self.path, prefix.split('/')[0..index].join('/'))
        completing_scope_path            = self.path if completing_scope_path.empty?
        prefix_within_completing_scope ||= (prefix.split('/').last || '')
      end
      [completing_scope_path, prefix_within_completing_scope]
    end

    def scopes_matching prefix
      scopes.find_all do |scope|
        prefix.empty? ? true : scope[0...prefix.length] == prefix
      end.map do |scope|
        scope =~ %r!/$! ? scope : scope + '/'
      end.sort.map do |scope|
        File.join(path, scope)
      end
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

  
