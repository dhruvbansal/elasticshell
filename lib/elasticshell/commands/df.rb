module Elasticshell
  module Commands
    class Df < Command

      def self.matches? input
        input =~ /^df/i
      end

      def evaluate!
        be_connected!
        global = shell.scope_from_path("/")
        global.status["indices"].each_pair do |index_name, data|
          size       = data["index"]["size_in_bytes"]
          human_size = data["index"]["size"]
          shell.print("%6s %6s \e[32m%s\e[0m" % [size, human_size, index_name])
        end
      end
      
    end
  end
end


