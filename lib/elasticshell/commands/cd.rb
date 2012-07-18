module Elasticshell
  module Commands
    class Cd < Command

      def self.matches? input
        input =~ /^cd/
      end

      def evaluate!
        if input =~ /^cd$/
          shell.scope = Scopes.global(:client => shell.client)
          return
        end
        
        return unless input =~ /^cd\s+(.+)$/
        scope = $1
        if scope =~ %r!^/!
          shell.scope = Scopes.from_path(scope, :client => shell.client)
        else
          shell.scope = Scopes.from_path(File.expand_path(File.join(shell.scope.path, scope)), :client => shell.client)
        end
      end

    end
  end
end

