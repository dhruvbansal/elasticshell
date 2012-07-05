require 'readline'
require 'uri'

require 'elasticshell/command'
require 'elasticshell/scopes'
require 'elasticshell/client'

module Elasticshell

  class Shell

    VERBS = %w[GET POST PUT DELETE]
    
    attr_accessor :client, :input, :command, :state, :only

    attr_reader :verb
    def verb= v
      raise ArgumentError.new("'#{v}' is not a valid HTTP verb.  Must be one of: #{VERBS.join(', ')}") unless VERBS.include?(v.upcase)
      @verb = v.upcase
    end

    attr_reader :scope
    def scope= scope
      @scope = scope
      proc = scope.completion_proc
      Readline.completion_proc = Proc.new do |prefix|
        self.state = :completion
        proc.call(prefix)
      end
    end

    def initialize options={}
      self.state  = :init
      self.client = Client.new(options)
      self.verb   = (options[:verb] || 'GET')
      self.scope  = Scopes.from_path((options[:scope] || '/'), :client => self.client)
      self.only   = options[:only]
      pretty! if options[:pretty]
    end

    def prompt
      "\e[1m#{prompt_verb_color}#{verb} #{prompt_scope_color}#{scope.path} #{prompt_prettiness_indicator} \e[0m"
    end

    def prompt_scope_color
      scope.exists? ? "\e[32m" : "\e[33m"
    end

    def prompt_verb_color
      verb == "GET" ? "\e[34m" : "\e[31m"
    end

    def prompt_prettiness_indicator
      pretty? ? '$' : '>'
    end
  
    def pretty?
      @pretty
    end

    def pretty!
      @pretty = true
    end

    def not_pretty!
      @pretty = false
    end

    def setup
      trap("INT") do
        int
      end

      Readline.completer_word_break_characters = " \t\n\"\\'`$><=|&{("
      
      puts <<EOF
Elasticshell v. #{Elasticshell.version}
Type "help" for contextual help.
EOF
    end

    def run
      setup
      loop
    end

    def loop
      self.state = :read
      while line = Readline.readline(prompt, true)
        eval_line(line)
      end
    end

    def eval_line line
      begin
        self.input   = line.strip
        self.command = Command.new(self, input)
        self.state = :eval
        self.command.evaluate!
      rescue ::Elasticshell::Error => e
        $stderr.puts e.message
      end
      self.state = :read
    end

    def print obj, ignore_only=false
      if self.only && !ignore_only
        only_parts = self.only.to_s.split('.')
        obj_to_print = obj
        while obj_to_print && only_parts.size > 0
          this_only = only_parts.shift
          obj_to_print = (obj_to_print || {})[this_only]
        end
        print(obj_to_print, true)
      else
        case
        when obj.nil?
        when obj.is_a?(String)
          puts obj
        else
          if pretty?
            puts JSON.pretty_generate(obj)
          else
            puts obj.to_json
          end
        end
      end
    end

    def int
      case self.state
      when :read
        $stdout.write("^C\n#{prompt}")
      else
        $stdout.write("^C...aborted\n#{prompt}")
      end
    end

    def clear_line
      while Readline.point > 0
        $stdin.write("\b \b")
      end
    end

    def die
      puts "C-d"
      print("C-d...quitting")
      exit()
    end

    def command_and_query_and_body command
      parts = command.split
      
      c_and_q = parts[0]
      c, q = c_and_q.split('?')
      o = {}
      URI.decode_www_form(q || '').each do |k, v|
        o[k] = v
      end

      path = parts[1]
      case
      when path && File.exist?(path) && File.readable?(path)
        b = File.read(path)
      when path && path == '-'
        b = $stdin.gets(nil)
      else
        b = ''
      end
      
      [c, o, b]
    end
    
    def request verb, params={}
      c, o, b = command_and_query_and_body(input)
      body    = (params.delete(:body) || b || '')
      print(client.request(verb, params.merge(:op => c), o, b))
    end

  end
  
end

