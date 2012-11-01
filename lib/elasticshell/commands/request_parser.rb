module Elasticshell
  module Commands
    class Request
      
      class Parser

        include RecognizesVerb
        
        attr_accessor :command, :raw, :verb, :request_string, :raw_path, :raw_body, :path, :query_options, :body

        def initialize(command)
          self.command = command
        end

        def request
          parse!
          { :verb => verb, :path => path, :query_options => query_options, :body => body }
        end
        
        def parse!
          strip_redirect!
          split_verb_and_request!
          split_path_and_body!
          interpret_path!
          construct_body!
        end

        def strip_redirect!
          self.raw = command.shell.input.gsub(/ (?:\||>).*$/,'')
        end

        def split_verb_and_request!
          if raw =~ Regexp.new("^(#{verb_re})\s+(.+)$", true)
            self.verb, self.request_string = canonicalize_verb($1), $2
          else
            self.verb, self.request_string = command.shell.verb, raw
          end
        end

        def split_path_and_body!
          self.raw_path, self.raw_body = request_string.split(/ /, 2)
        end

        def interpret_path!
          relative_path, query_string = raw_path.split('?')
          self.path = File.expand_path(relative_path, command.shell.scope.path)
          
          self.query_options = {}
          URI.decode_www_form(query_string || '').each do |k, v|
            self.query_options[k] = v
          end
        end

        def construct_body!
          self.body = case
          when raw_body.nil?
            ''
          when raw_body == '-'
            Elasticshell.info("Reading request body from STDIN.  Press `C-d' to terminate input...")
            command.shell.input_stream.gets(nil)
          when File.exist?(raw_body)
            File.read(raw_body)
          else
            raw_body
          end
        end
        
      end
    end
  end
end

      
