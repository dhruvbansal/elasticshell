require 'rubberband'
require 'timeout'

module Elasticshell

  class Client

    def initialize options={}
      @options = options
    end

    def connect options={}
      servers = (@options.merge(options)[:servers] || Settings[:servers].to_s.split(","))
      raise ClientError.new("Must provide at least one server to connect to.") if servers.empty?
      begin
        Elasticshell.debug("Connecting to Elasticsearch servers: #{servers.join(', ')}")
        begin
          timeout(5) do
            @client = ElasticSearch::Client.new(servers)
          end
        rescue Timeout::Error => e
          Elasticshell.error("Could not connect to Elasticsearch servers: #{servers.join(', ')}")
          return
        end
        Elasticshell.info("Connected to Elasticsearch servers: #{servers.join(', ')}")
      rescue ElasticSearch::ConnectionFailed => e
        raise ClientError.new("Could not connect to Elasticsearch server: #{servers.join(', ')}")
      end
    end

    def connected?
      @client
    end

    def request verb, params={}, options={}, body=''
      raise ClientError.new("Not connected to any Elasticsearch servers.") unless connected?
      safe        = options.delete(:safely)
      safe_return = options.delete(:return)
      
      # Log by default
      log_request(verb, params, options) unless options.delete(:log) == false
      
      begin
        perform_request(verb, params, options, body)
      rescue ElasticSearch::RequestError, ArgumentError => e
        if safe
          safe_return
        else
          raise ClientError.new(e.message)
        end
      end
    end

    def perform_request verb, params, options, body
      @client.execute(:standard_request, verb.downcase.to_sym, params, options, body)
    end

    def log_request verb, params, options={}
      # begin
        # FIXME digging way too deep into rubberband here...is it really
      # necessary?
        uri   = @client.instance_variable_get('@connection').send(:generate_uri, params)
        query = @client.instance_variable_get('@connection').send(:generate_query_string, options)
        path  = [uri, query].reject { |s| s.nil? || s.strip.empty? }.join("?").gsub(Regexp.new("^/+"), "/")
        Elasticshell.request(verb, @client.current_server, path)
      # rescue
      #   Elasticshell.info(verb, path, "#{verb.to_s.upcase} #{params.inspect} #{options.inspect}".strip)
      # end
    end

    def safely verb, params={}, options={}, body=''
      request(verb, params, options.merge(:safely => true))
    end
  
  end

end
