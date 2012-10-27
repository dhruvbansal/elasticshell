module Elasticshell
  module Commands
    class Exit < Command

      def self.matches? input
        input =~ /^(quit|exit|bye)$/i
      end

      def evaluate!
        exit(0)
      end
      
    end
  end
end
