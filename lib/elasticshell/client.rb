require 'rubberband'

module Elasticshell

  class Client

    def initialize options={}
      @options = options
    end

    def connect options={}
      servers = (options.merge(@options)[:servers] || Settings[:servers].to_s.split(","))
      begin
        @client = ElasticSearch::Client.new(servers)
      rescue ElasticSearch::ConnectionFailed => e
        raise ClientError.new("Could not connect to Elasticsearch server(s) at #{servers.join(',')}")
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
      begin
        # FIXME digging way too deep into rubberband here...is it really
        # necessary?
        uri   = @client.instance_variable_get('@connection').send(:generate_uri, params)
        query = @client.instance_variable_get('@connection').send(:generate_query_string, options)
        path  = [uri, query].reject { |s| s.nil? || s.strip.empty? }.join("?").gsub(Regexp.new("^/+"), "/")
        Elasticshell.log("#{verb.to_s.upcase} #{path}".strip)
      rescue
        Elasticshell.log("#{verb.to_s.upcase} #{params.inspect} #{options.inspect}".strip)
      end
    end

    def safely verb, params={}, options={}, body=''
      request(verb, params, options.merge(:safely => true))
    end
  
  end

end
