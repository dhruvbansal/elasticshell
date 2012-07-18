module Elasticshell
  module Commands
    class Blank < Command

      def self.matches? input
        input.empty?
      end

      def evaluate!
      end
      
    end
  end
end
