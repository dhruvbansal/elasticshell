require 'rubygems'
require 'json'
require 'configliere'

require 'elasticshell/shell'
require 'elasticshell/scopes'
require 'elasticshell/client'

Settings.use(:commandline)

Settings.define(:servers, :description => "A comma-separated list of Elasticsearch servers to connect to.", :type => Array, :default => Elasticshell::Client::DEFAULT_SERVERS)
Settings.define(:only,    :description => "A dot-separated hierarchical key to extract from the output scope.")
Settings.define(:pretty,  :description => "Pretty-print all output. ", :default => false, :type => :boolean)
Settings.define(:verb,    :description => "Set the default HTTP verb. ", :default => "GET")
Settings.resolve!

module Elasticshell

  def self.version
    @version ||= begin
      File.read(File.expand_path('../../VERSION', __FILE__)).chomp
    rescue => e
      'unknown'
    end
  end
  
  def self.start *args
    es = Shell.new(Settings)
    if Settings[:only]
      if Settings.rest.length == 0
        $stderr.puts "Starting with the --only option requires the first argument to name an API path (like `/_cluster/health')"
        exit(1)
      else
        es.eval_line(Settings.rest.first)
        exit()
      end
    else
      if Settings.rest.length > 0
        es.scope = Scopes.from_path(Settings.rest.first, :client => es.client)
      end
      es.run
    end
  end
  
end
