require 'rubberband'
require 'timeout'

module Elasticshell

  class Client

    def initialize options={}
      @options = options
    end

    def safely_connect options={}
      servers = @options.merge(options)[:servers]
      raise ClientError.new("Must provide at least one server to connect to.") if servers.empty?
      connect(servers.dup, first_attempt=true)
    end

    def connected?
      @client
    end

    def safely verb, params={}, options={}, body=''
      request(verb, params, options.merge(:safely => true))
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
    
    private

    def connect servers, first_attempt=false
      string  = servers.join(' ')
      Elasticshell.debug("Attempting to connect to #{string} ...")         if first_attempt
      raise ClientError.new("Timed out or failed to connect to #{string}") if servers.empty?
      begin
        server = servers.shift
        timeout(5) do
          @client = ElasticSearch::Client.new(server)
          Elasticshell.info("Connected to #{server}")
        end
      rescue Timeout::Error => e
        Elasticshell.debug("Timed out connecting to #{server}")
        connect(servers)
      rescue ElasticSearch::ConnectionFailed => e
        Elasticshell.debug("Failure connecting to #{server}")
        connect(servers)
      rescue => e
        Elasticshell.error("#{e.class} -- #{e.message}")
        connect(servers)
      end
    end

    def perform_request verb, params, options, body
      # p [verb, params, options, body]
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

  end

end
