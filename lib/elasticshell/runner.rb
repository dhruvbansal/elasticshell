module Elasticshell

  ORIG_ARGV = ARGV.dup.freeze

  Settings.use(:commandline)
  Settings.define(:servers, :description => "A comma-separated list of Elasticsearch servers to connect to.", :type => Array, :default => ['localhost:9200'])
  Settings.define(:config,  :description => "Path to an Elasticsearch config file to read settings from", :default => '/etc/elasticsearch/elasticsearch.yml')
  Settings.define(:only,    :description => "A dot-separated hierarchical key to extract from the output scope.")
  Settings.define(:pretty,  :description => "Pretty-print all output. ", :default => false, :type => :boolean)
  Settings.define(:verb,    :description => "Set the default HTTP verb. ", :default => "GET")
  Settings.define(:version, :description => "Print Elasticshell version and exit. ", :default => false, :type => :boolean)
  Settings.define(:scope,   :description => "The default scope to start the shell in.", :default => "/")
  Settings.define(:eval,    :description => "Evaluate given Ruby code on response.")
  Settings.description = <<-DESC
Elasticshell is a command-line shell for interacting with an
Elasticsearch database.  It has the following start-up options.
DESC

  def Settings.usage
    "usage: #{File.basename($0)} [OPTIONS] [REQUEST]"
  end

  def self.overrode_servers_on_command_line?
    ORIG_ARGV.any? { |arg| arg =~ /--servers/ }
  end

  def self.find_servers_from_config_file! path=nil
    return if overrode_servers_on_command_line?
    file = ElasticsearchConfigFile.new(path || Settings[:config])
    Settings[:servers] = file.hosts if file.readable? && (!file.hosts.empty?)
  end
  
  def self.start *args
    begin
      Settings.resolve!
      find_servers_from_config_file!
      case
      when Settings[:version]
        puts version
        exit()
      when (Settings[:only] || Settings[:eval]) && Settings.rest.empty?
        raise ArgumentError.new("Starting with the --only or --eval options requires a request argument (like `/_cluster/health')")
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
      Elasticshell.error(e.message)
      exit(2)
    end
  end

end
