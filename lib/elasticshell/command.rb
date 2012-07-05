require 'elasticshell/error'
require 'uri'

module Elasticshell

  class Command

    HTTP_VERB_RE = "(?:G(?:ET?)?|PO(?:ST?)?|PUT?|D(?:E(?:L(?:E(?:TE?)?)?)?)?)"

    attr_accessor :shell, :input

    def initialize shell, input
      self.shell = shell
      self.input = input
    end

    def evaluate!
      case
      when setting_scope?          then set_scope!
      when setting_http_verb?      then set_http_verb!
      when making_explicit_req?    then make_explicit_req!
      when pretty?                 then pretty!
      when help?                   then help!
      when ls?                     then ls!
      when blank?                  then nil
      when scope_command?          then run_scope_command!        
      else
        raise ArgumentError.new("Unknown command '#{input}' for scope '#{shell.scope.path}'.  Try typing 'help' for a list of available commands.")
      end
    end

    def setting_scope?
      input =~ /^cd/
    end

    def set_scope!
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

    def setting_http_verb?
      input =~ Regexp.new("^" + HTTP_VERB_RE + "$", true)
    end

    def canonicalize_http_verb v
      case v
      when /^G/i  then "GET"
      when /^PO/i then "POST"
      when /^PU/i then "PUT"
      when /^D/i  then "DELETE"
      end
    end

    def set_http_verb!
      shell.verb = canonicalize_http_verb(input)
    end

    def scope_command?
      shell.scope.command?(input)
    end

    def run_scope_command!
      shell.scope.execute(input, shell)
    end

    def blank?
      input.empty?
    end

    def help?
      input =~ /^help/i
    end

    def help!
      shell.scope.refresh
      shell.print <<HELP

Globally available commands:

  cd [PATH]
    Change scope to the given path.  Current path is reflected in the
    prompt (it's '#{shell.scope.path}' right now).

    Ex:
      GET / > cd /my_index
      GET /my_index > cd /other_index/some_type
      GET /other_index/some_type

  [get|post|put|delete]
    Set the default HTTP verb (can use a non-ambiguous shortcut like 'g'
    for 'GET' or 'pu' for 'PUT').  Current default HTTP verb is '#{shell.verb}'.

  ls
    Show what indices or mappings are within the current scope.

  help
    Show contextual help.

  [VERB] PATH
    Send an HTTP request with the given VERB to the given PATH
    (including query string if given).  If no verb is given, use the
    default.

    Ex: Simple search
      GET / > /my_index/_search?q=query+string
      {...}

    Ex: Create an index
      GET / > PUT /my_new_index
      {...}

      or

      GET / > put
      PUT / > /my_new_index
      {...}

#{shell.scope.help}
HELP
    end

    def ls?
      input =~ /^l(s|l|a)?$/i
    end

    def ls!
      shell.scope.refresh!
      case
      when input =~ /ll/
        shell.print shell.scope.contents.join("\n")
      else
        shell.print shell.scope.contents.join(' ')
      end
    end

    def pretty?
      input =~ /pretty/i
    end

    def pretty!
      if shell.pretty?
        shell.not_pretty!
      else
        shell.pretty!
      end
    end

    def making_explicit_req?
      input =~ Regexp.new("^(" + HTTP_VERB_RE + "\s+)?/", true)
    end

    def make_explicit_req!
      if input =~ Regexp.new("^(" + HTTP_VERB_RE + ")\s+(.+)$", true)
        verb, path_and_query = canonicalize_http_verb($1), $2
      else
        verb, path_and_query = shell.verb, input
      end
      path, query = path_and_query.split('?')
      
      params = {}
      keys  = [:index, :type, :id, :op]
      parts = path.gsub(%r!^/!,'').gsub(%r!/$!,'').split('/')
      while parts.size > 0
        part = parts.shift
        key  = (keys.shift or ArgumentError.new("The input '#{path}' has too many path components."))
        params[key] = part
      end

      options = {}
      URI.decode_www_form(query || '').each do |key, value|
        options[key] = value
      end
      
      shell.print(shell.client.request(verb.downcase.to_sym, params, options))
    end
    
    
  end
  
end

