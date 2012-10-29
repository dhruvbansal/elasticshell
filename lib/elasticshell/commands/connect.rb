require 'uri'

module Elasticshell
  module Commands
    class Connect < Command

      def self.matches? input
        input =~ /^connect(?: |$)/i
      end

      def evaluate!
        servers = (input.split(/\s+/, 2)[1] || '').split(/\s+/)
        if servers.empty?
          shell.client.safely_connect()
        else
          uris = servers.map do |raw|
            has_port = raw =~ /:\d+/
            cooked  = (raw =~ /^http:\/\// ? raw : 'http://' + raw)
            cooked += '/' unless cooked =~ /\/$/
            begin
              uri = URI.parse(cooked)
              if uri.path == '/'
                uri.port = 9200 unless has_port
                uri.to_s
              else
                Elasticshell.warn("#{raw} is not a valid URI for an ElasticSearch server")
                nil
              end
            rescue => e
              Elasticshell.warn("#{raw} is not a valid URI")
              nil
            end
          end.compact
          shell.client.safely_connect(:servers => uris)
        end
      end

      

    end
  end
end

