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
          shell.client.connect()
        else
          servers.each do |server|
            begin
              uri = URI.parse(server + "/")
            rescue => e
              raise ArgumentError.new("#{server} is not a valid URI")
            end
            raise ArgumentError.new("#{server} is not a valid URI for an ElasticSearch server") unless uri.path == '/'
          end
          shell.client.connect(:servers => servers)
        end
      end

    end
  end
end

