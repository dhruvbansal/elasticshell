require 'rubygems'
require 'json'
require 'configliere'

require 'elasticshell/utils'

Settings.use(:commandline)

Settings.define(:servers, :description => "A comma-separated list of Elasticsearch servers to connect to.", :type => Array, :default => 'http://localhost:9200')
Settings.define(:only,    :description => "A dot-separated hierarchical key to extract from the output scope.")
Settings.define(:pretty,  :description => "Pretty-print all output. ", :default => false, :type => :boolean)
Settings.define(:verb,    :description => "Set the default HTTP verb. ", :default => "GET")
Settings.define(:version, :description => "Print Elasticshell version and exit. ", :default => false, :type => :boolean)
Settings.define(:scope,   :description => "The default scope to start the shell in.", :default => "/")
Settings.description = <<-DESC
Elasticshell is a command-line shell for interacting with an
Elasticsearch database.  It has the following start-up options.
DESC

def Settings.usage
  "usage: #{File.basename($0)} [OPTIONS] [REQUEST]"
end
Settings.resolve!

module Elasticshell

  autoload :Client,   'elasticshell/client'
  autoload :Shell,    'elasticshell/shell'
  autoload :Scope,    'elasticshell/scopes'
  autoload :Scopes,   'elasticshell/scopes'
  autoload :Command,  'elasticshell/command'
  autoload :Commands, 'elasticshell/command'

  def self.version
    @version ||= begin
                   File.read(File.expand_path('../../VERSION', __FILE__)).chomp
                 rescue => e
                   'unknown'
                 end
  end
  
  def self.start *args
    begin
      case
      when Settings[:version]
        puts version
        exit()
      when Settings[:only] && Settings.rest.empty?
        raise ArgumentError.new("Starting with the --only option requires a request argument (like `/_cluster/health')")
        exit(1)
      when (! Settings.rest.empty?)
        es = Shell.new(Settings.merge(:log_requests => false))
        es.connect
        es.eval_line(Settings.rest.first)
        exit()
      else
        Shell.new(Settings).run
      end
    rescue Elasticshell::Error => e
      $stderr.puts e.message
      exit(2)
    end
  end
end
