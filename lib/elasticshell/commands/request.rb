module Elasticshell
  module Commands
    class Request < Command

      extend  RecognizesVerb

      attr_accessor :response, :request

      def self.matches? input
        input =~ Regexp.new("^(#{verb_re}\s+)?.", true)
      end

      def parse!
        self.request = Parser.new(self).request
      end

      def perform_request!
        self.response = shell.client.safely(request[:verb], {:op => request[:path].gsub(/^\//,'') }, request[:query_options].merge(:log => shell.log_requests?), request[:body])
      end

      def pipe?
        pipe_to_ruby? || pipe_to_irb? || pipe_to_file?
      end

      def pipe_to_file?
        input =~ /\s>\s*.+$/
      end

      def output_filename
        input =~ /\s>\s*(.+)$/
        $1
      end

      def pipe_to_file!
        File.open(output_filename, 'w') { |f| f.puts response.to_s }
      end
      
      def pipe_to_irb?
        input =~ /\s\|\s*$/
      end

      def irb!
        require 'ripl'
        Ripl.start(:binding => binding)
      end

      def pipe_to_ruby?
        input =~ /\s\|\s*\S+/
      end
      
      def ruby_code
        return unless pipe?
        input =~ /\s\|(.*)$/
        $1.to_s
      end

      def ruby!
        eval(ruby_code, binding)
      end
      
      def evaluate!
        be_connected!
        parse!
        perform_request!
        case
        when pipe_to_irb?
          irb!
        when pipe_to_ruby?
          ruby!
        when pipe_to_file?
          pipe_to_file!
        else
          shell.print(response)
        end
      end
      
    end
  end
end

require 'elasticshell/commands/request_parser'
