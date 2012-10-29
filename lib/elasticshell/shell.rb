require 'readline'
require 'uri'

module Elasticshell

  class Shell

    Settings.define(:passive_http_verb_format,
                    :description => "Format string for the passive HTTP verb GET.  The string `%v' will be replaced by the verb.",
                    :default     => "\e[34m%v",
                    :internal    => true)
    
    Settings.define(:active_http_verb_format,
                    :description => "Format string for the active HTTP verbs PUT, POST, and DELETE.  The string `%v' will be replaced by the verb.",
                    :default     => "\e[31m%v",
                    :internal    => true)
    
    Settings.define(:existing_scope_format,
                    :description => "Format string for an existing scope.  The string `%s' will be replaced by the scope name.",
                    :default     => "\e[32m%s",
                    :internal    => true)
    
    Settings.define(:missing_scope_format,
                    :description => "Format string for scope which doesn't exist.  The string `%s' will be replaced by the scope name.",
                    :default     => "\e[33m%s",
                    :internal    => true)
    
    Settings.define(:prompt_format,
                    :description => "Format string for the prompt.  The strings `%v' and `%s' will be replaced by the (already-formatted) HTTP verb and current scope name.",
                    :default     => "\e[1m%v %s$ \e[0m",
                    :internal    => true)
    
    Settings.define(:pretty_prompt_format,
                    :description => "Format string for the prompt when in pretty-mode.  The strings `%v' and `%s' will be replaced by the (already-formatted) HTTP verb and current scope name.",
                    :default     => "\e[1m%v %s$$ \e[0m",
                    :internal    => true)
    
    Settings.define(:scope_long_format,
                    :description => "Format string for displaying a scope in a long (`ll') listing.  The string `%s' will be replaced by the scope name.",
                    :default     => "s                          \e[32m%s\e[0m",
                    :internal    => true)

    Settings.define(:index_long_format,
                    :description => "Format string for displaying an index in a long (`ll') listing.  The string `%n' will be replaced by the index name, `%T' with the total number of shards, `%S' with the number of successful shards, `%F' with the number of failed shards, `%s' with the size in bytes, `%h' with the human-readable size",
                    :default     => "d  %S/%F  %h  \e[32m%n\e[0m",
                    :internal    => true)
    
    Settings.define(:request_long_format,
                    :description => "Format string for displaying a request in a long (`ll') listing.  The string `%r' will be replaced by the request name.",
                    :default     => "-                          %r",
                    :internal    => true)
    
    Settings.define(:scope_format,
                    :description => "Format string for displaying a scope in a listing.  The string `%s' will be replaced by the scope name.",
                    :default     => "\e[32m%s\e[0m",
                    :internal    => true)
    
    Settings.define(:request_format,
                    :description => "Format string for displaying a request in a listing.  The string `%r' will be replaced by the request name.",
                    :default     => "%r",
                    :internal    => true)
    
    include Elasticshell::HasVerb

    attr_accessor :client, :state, :only, :ruby_code, :input, :cache, :output, :line, :input_stream

    attr_reader :scope
    def scope= scope
      @scope = scope
      proc = scope.completion_proc
      Readline.completion_proc = Proc.new do |prefix|
        self.state = :completion
        proc.call(self, prefix)
      end
    end

    def path
      scope.path
    end

    def connected?
      client.connected?
    end

    def initialize options={}
      @interactive = false
      self.state  = :init
      self.client = Client.new(options)
      self.cache  = {}
      @initial_servers = (options[:servers] || [])
      self.verb   = (options[:verb] || 'GET')
      self.scope  = scope_from_path(options[:scope] || '/')
      self.only   = options[:only]
      self.ruby_code = options[:eval]
      self.input_stream  = (options[:input]  || $stdin)
      self.output = (options[:output] || $stdout)
      self.line   = 0
      @log_requests = (options[:log_requests] == false ? false : true)
      pretty! if options[:pretty]
    end

    def scope_from_path path
      if cache[path]
        cache[path]
      else
        cache[path] = Scopes.from_path(path, :client => self.client)
      end
    end

    def prompt
      verb_string  = Elasticshell.format((verb.to_s =~ /^(?:G|H)/i ? :passive_http_verb_format : :active_http_verb_format), "%v", verb.to_s.upcase)
      scope_string = Elasticshell.format((scope.exists? ? :existing_scope_format : :missing_scope_format), "%s", scope.path)
      Elasticshell.format((pretty? ? :pretty_prompt_format : :prompt_format), ["%s", "%v"], [scope_string, verb_string])
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

    def interactive?
      @interactive
    end

    def setup
      trap("INT") do
        int
      end

      Readline.completer_word_break_characters = " \t\n\"\\'`$><=|&{("
      
      print <<EOF
Elasticshell v. #{Elasticshell.version}
Type "help" for contextual help.
EOF
      @interactive = true

      self.line = 1
    end

    def run
      setup
      connect
      loop
    end

    def connect
      eval_line("connect #{@initial_servers.join(' ')}")
    end

    def loop
      self.state = :read
      while line = Readline.readline(prompt, true)
        eval_line(line)
      end
      die
    end

    def eval_line line
      begin
        self.state = :eval
        self.input = line.strip
        command.evaluate!
      rescue ::Elasticshell::Error => e
        Elasticshell.error e.message
      end
      self.state = :read
      self.line += 1
      self
    end

    def command
      matching_command_class_name = Commands::PRIORITY.detect do |command_class_name|
        Commands.const_get(command_class_name).matches?(input)
      end
      
      # We should never hit the following ArgumentError as there
      # exists a catch-all command: Unknown
      raise ArgumentError.new("Could not parse command: '#{input}'") unless matching_command_class_name
      
      Commands.const_get(matching_command_class_name).new(self, input)
    end
    
    def print obj, ignore_only=false
      self.output.puts(format_output(obj, ignore_only))
    end

    def format_output obj, ignore_only=false
      case
      when self.only == true && !ignore_only
        format_output(obj, true)
      when self.only && !ignore_only
        format_only_part_of(obj)
      when obj.nil?
        nil
      when obj.is_a?(String) || obj.is_a?(Fixnum)
        obj
      when pretty?
        JSON.pretty_generate(obj)
      else
        obj.to_json
      end
    end

    def format_only_part_of obj
      only_parts = self.only.to_s.split('.')
      obj_to_print = obj
      while obj_to_print && only_parts.size > 0
        this_only = only_parts.shift
        obj_to_print = (obj_to_print || {})[this_only]
      end
      format_output(obj_to_print, true)
    end

    def int
      case self.state
      when :read
        $stdout.write("^C\n#{prompt}")
      else
        $stdout.write("^C...aborted\n#{prompt}")
      end
    end

    def die
      raise ShellError.new("C-d...quitting")
    end

    def log_requests?
      @log_requests
    end

  end
end
