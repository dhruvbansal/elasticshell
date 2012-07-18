module Elasticshell
  module Commands
    class Connect < Command

      def self.matches? input
        input =~ /^connect(?: |$)/i
      end

      def evaluate!
        servers = (input.split(/ /, 2)[1] || '').split(/ *, */)
        if servers.empty?
          shell.client.connect()
        else
          shell.client.connect(:servers => servers)
        end
      end

    end
  end
end

