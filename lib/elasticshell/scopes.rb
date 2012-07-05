require 'elasticshell/error'
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

    attr_accessor :path, :client, :last_refresh_at, :contents

    def initialize path, options
      self.path     = path
      self.client   = options[:client]
      self.contents = initial_contents
    end

    def to_s
      self.path
    end

    def completion_proc
      Proc.new do |prefix|
        refresh
        case
        when Readline.line_buffer =~ /^\s*cd\s+\S*$/
          contents.find_all do |content|
            content[0...prefix.length] == prefix
          end
        when Readline.line_buffer =~ /^\s*\S*$/
          command_names.find_all do |command_name|
            command_name[0...prefix.length] == prefix
          end
        else
          Dir[prefix + '*']
        end
      end
    end

    def command_names
      refresh
      commands.keys.sort
    end

    def commands
      {}
    end

    def refresh
      refresh! unless refreshed?
    end

    def refresh!
      reset!
      fetch_contents
      self.last_refresh_at = Time.now
      true
    end

    def fetch_contents
    end

    def initial_contents
      []
    end

    def reset!
      self.contents = initial_contents
      true
    end

    def refreshed?
      self.last_refresh_at
    end

    def exists?
      false
    end

    def command? command
      command_names.any? do |command_name|
        command[0...command_name.length] == command_name
      end
    end

    def execute command, shell
      if command_names.include?(command)
        raise NotImplementedError.new("Have not yet implemented '#{command}' for scope '#{path}'.")
      else
        raise ArgumentError.new("No such command '#{command}' in scope '#{path}'.")
      end
    end

    def help
      [].tap do |msg|
        msg << "Commands specific to the scope '#{path}':"
        msg << ''
        commands.each_pair do |command_name, description|
          msg << '  ' + command_name
          msg << ('    ' + description)
          msg << ''
        end
      end.join("\n")
    end

  end
  
end

  
