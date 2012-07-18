require 'elasticshell/utils/recognizes_verb'

module Elasticshell
  module Commands
    class SetVerb < Command

      include RecognizesVerb
      extend  RecognizesVerb

      def self.matches? input
        is_http_verb?(input)
      end

      def evaluate!
        v = canonicalize_verb(input)
        shell.verb = v
        shell.scope.verb = v
      end
      
    end
  end
end

