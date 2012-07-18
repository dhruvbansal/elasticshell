module Elasticshell
  module Commands
    class Unknown < Command

      def self.matches? input
        true
      end

      def evaluate!
        $stderr.puts "Invalid command: '#{shell.input}' for scope '#{shell.scope.path}'.  Try typing 'help' for a list of available commands."
      end
      
    end
  end
end


