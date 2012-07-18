module Elasticshell
  module Commands
    class Pwd < Command

      def self.matches? input
        input =~ /^pwd/i
      end

      def evaluate!
        shell.print shell.scope.path
      end
      
    end
  end
end


