require 'elasticshell/utils/recognizes_verb'

module Elasticshell
  module Commands
    class Request < Command

      include RecognizesVerb
      extend  RecognizesVerb

      def self.matches? input
        input =~ Regexp.new("^(#{verb_re}\s+)?.", true)
      end

      def parse input
        if input =~ Regexp.new("^(#{verb_re})\s+(.+)$", true)
          verb, request = canonicalize_verb($1), $2
        else
          verb, request = shell.verb, input
        end
        
        path_arg, body_arg = request.split(/ /, 2)
        
        relative_path, query_string = path_arg.split('?')

        path = File.expand_path(relative_path, shell.scope.path)
        
        query_options = {}
        URI.decode_www_form(query_string || '').each do |k, v|
          query_options[k] = v
        end

        case
        when body_arg.nil?
          body = ''
        when body_arg == '-'
          body = $stdin.gets(nil)
        when File.exist?(body_arg)
          body = File.read(body_arg)
        else
          body = body_arg
        end

        { :verb => verb, :path => path, :query_options => query_options, :body => body }
      end

      def evaluate!
        be_connected!
        request = parse(input)
        # p request
        shell.print(shell.client.request(request[:verb].downcase.to_sym, {:op => request[:path] }, request[:query_options], request[:body]))
      end
    end
  end
end
