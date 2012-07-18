module Elasticshell
  module Commands
    class Ls < Command

      attr_accessor :scope

      def self.matches? input
        input =~ /^l(s|l|a)?(?: .+)?$/i
      end

      def evaluate!
        be_connected!
        if input =~ /^l(?:s|l|a)? +(.+)$/
          self.scope = shell.scope_from_path($1)
        else
          self.scope = shell.scope
        end
        self.scope.refresh!
        input =~ /^ll/ ? ll! : ls!
      end

      def ll!
        scope.scopes.sort.each do |scope|
          shell.print shell.format(:scope_long_format, "%s", scope)
        end
        scope.request_names.sort.each do |request|
          shell.print shell.format(:request_long_format, "%r", request)
        end
      end

      def ls!
        output = []
        scope.scopes.sort.map do |scope|
          output << shell.format(:scope_format, "%s", scope)
        end
        scope.request_names.sort.map do |request|
          output << shell.format(:request_format, "%r", request)
        end
        shell.print output.join(' ')
      end
      
    end
  end
end


