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
        input =~ /^l(?:l|a)/ ? ll! : ls!
      end

      def sort array
        with_underscores    = array.find_all { |element| element =~ /^_/    }
        without_underscores = array.find_all { |element| element =~ /^[^_]/ }
        without_underscores.sort + with_underscores.sort
      end

      def ll!
        sort(scope.scopes).each do |scope_name|
          case
          when scope.path == '/' && scope.indices.include?(scope_name)
            index = shell.scope_from_path("/#{scope_name}")
            total_shards = index.status["_shards"]["total"]
            succ_shards  = index.status["_shards"]["successful"]
            fail_shards  = index.status["_shards"]["failed"]
            size         = index.status["indices"][scope_name]["index"]["size_in_bytes"]
            human_size   = index.status["indices"][scope_name]["index"]["size"]
            num_docs     = index.status["indices"][scope_name]["docs"]["num_docs"]
            shell.print("i %10s %6s %6s \e[32m%s\e[0m" % ["#{total_shards}/#{succ_shards}/#{fail_shards}", num_docs, human_size, scope_name])
          when scope.class == Scopes::Index && scope.mappings.include?(scope_name)
            shell.print("m                          \e[32m%s\e[0m" % [scope_name])
          else
            shell.print shell.format(:scope_long_format, "%s", scope_name)
          end
        end
        sort(scope.request_names).each do |request|
          shell.print shell.format(:request_long_format, "%r", request)
        end
      end

      def ls!
        output = []
        sort(scope.scopes).map do |scope|
          output << shell.format(:scope_format, "%s", scope)
        end
        sort(scope.request_names).map do |request|
          output << shell.format(:request_format, "%r", request)
        end
        shell.print output.join(' ')
      end
      
    end
  end
end


