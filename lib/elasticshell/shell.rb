require 'readline'
require 'uri'

require 'elasticshell/client'
require 'elasticshell/command'
require 'elasticshell/scopes'
require 'elasticshell/utils/has_verb'

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
                    :default     => "d	\e[32m%s\e[0m",
                    :internal    => true)
    
    Settings.define(:request_long_format,
                    :description => "Format string for displaying a request in a long (`ll') listing.  The string `%r' will be replaced by the request name.",
                    :default     => "-	%r",
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

    attr_accessor :client, :state, :only, :input

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
      @interactive = false
      self.state  = :init
      self.client = Client.new(options)
      @initial_servers = (options[:servers] || [])
      self.verb   = (options[:verb] || 'GET')
      self.scope  = scope_from_path(options[:scope] || '/')
      self.only   = options[:only]
      pretty! if options[:pretty]
    end

    def scope_from_path path
      Scopes.from_path(path, :client => self.client)
    end

    def format name, codes, values
      cs = [codes].flatten
      vs = [values].flatten
      raise ArgumentError.new("Must provide the same number of format codes as value strings.") unless cs.length == vs.length
      Settings[name].dup.tap do |s|
        cs.each_with_index do |c, index|
          v = vs[index]
          s.gsub!(c, v)
        end
      end
    end

    def prompt
      verb_string  = format((verb =~ /^(?:G|H)/i ? :passive_http_verb_format : :active_http_verb_format), "%v", verb)
      scope_string = format((scope.exists? ? :existing_scope_format : :missing_scope_format), "%s", scope.path)
      format((pretty? ? :pretty_prompt_format : :prompt_format), ["%s", "%v"], [scope_string, verb_string])
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
    end

    def run
      setup
      loop
    end

    def loop
      self.state = :read
      eval_line("connect #{@initial_servers.join(',')}")
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
        $stderr.puts e.message
      end
      self.state = :read
    end

    def command
      klass = Commands::PRIORITY.detect { |command_class| command_class.matches?(input) }
      
      # We should never hit the following ArgumentError as there
      # exists a catch-all command: Unknown
      raise ArgumentError.new("Could not parse command: '#{input}'") unless klass
      
      klass.new(self, input)
    end
    
    def print obj, ignore_only=false
      if self.only && !ignore_only
        if self.only == true
          print(obj, true)
        else
          only_parts = self.only.to_s.split('.')
          obj_to_print = obj
          while obj_to_print && only_parts.size > 0
            this_only = only_parts.shift
            obj_to_print = (obj_to_print || {})[this_only]
          end
          print(obj_to_print, true)
        end
      else
        case obj
        when nil
        when String, Fixnum
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

    def die
      raise ShellError.new("C-d...quitting")
    end

  end
end
