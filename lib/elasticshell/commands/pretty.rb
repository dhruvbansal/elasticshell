module Elasticshell
  module Commands
    class Pretty < Command

      def self.matches? input
        input =~ /^pretty/i
      end

      def evaluate!
        if shell.pretty?
          shell.not_pretty!
        else
          shell.pretty!
        end
      end
      
    end
  end
end


