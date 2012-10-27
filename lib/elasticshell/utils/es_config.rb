require 'yaml'

module Elasticshell

  class ElasticsearchConfigFile

    attr_accessor :path

    def initialize path
      self.path = path
    end

    def readable?
      File.exist?(path) && File.readable?(path)
    end

    def config
      @config ||= YAML.load(File.new(path))
    end

    def hosts
      return @hosts if @hosts
      Elasticshell.debug("Looking for Elasticsearch hosts in #{path}...")
      unicast_hosts   = (config["discovery"]["zen"]["ping"]["unicast"]["hosts"] rescue nil)
      unicast_hosts ||= (config["discovery"]["zen"]["ping"]["unicast.hosts"]    rescue nil)
      unicast_hosts ||= (config["discovery"]["zen"]["ping.unicast.hosts"]       rescue nil)
      unicast_hosts ||= (config["discovery"]["zen.ping.unicast.hosts"]          rescue nil)
      unicast_hosts ||= (config["discovery"]["zen.ping.unicast.hosts"]          rescue nil)
      unicast_hosts ||= (config["discovery.zen.ping.unicast.hosts"]             rescue nil)
      @hosts = case unicast_hosts
      when String then unicast_hosts.split(',').map(&:strip)
      when Array  then unicast_hosts.map(&:to_s).map(&:strip)
      else
        []
      end.map do |unicast_host|
        host(unicast_host)
      end
    end

    def http_port
      return @http_port if @http_port
      port_string   = (config["http"]["port"] rescue nil)
      port_string ||= (config["http.port"]    rescue nil)
      @http_port = case port_string
      when String, Fixnum then port_string.to_i
      else 9200
      end
    end
    
    private

    def host string
      case string
      when /^(.+)\[(.+)-(.+)\]$/ then [$1, $2].join(':')
      when /^(.+):(.+)$/         then [$1, $2].join(':')
      else
        [string, http_port].map(&:to_s).join(':')
      end
    end


  end
end
