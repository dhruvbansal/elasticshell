module Elasticshell
  module Commands
    class Help < Command

      def self.matches? input
        input =~ /^help/i
      end

      def evaluate!
        shell.print <<HELP

Globally available commands:

  cd [PATH]
    Change scope to the given path.  Current path is reflected in the
    prompt (it's '#{shell.scope.path}' right now).

    Ex:
      GET /$ cd /my_index
      GET /my_index$ cd /other_index/some_type
      GET /other_index/some_type$

  [get|post|put|delete]
    Set the default HTTP verb (can use a non-ambiguous shortcut like 'g'
    for 'GET' or 'pu' for 'PUT').  Current default HTTP verb is '#{shell.verb}'.

  ls
    Show what indices or mappings are within the current scope.
    Try 'll' for a long listing.

  help
    Show contextual help.

  [VERB] PATH
    Send an HTTP request with the given VERB to the given PATH
    (including query string if given).  If no verb is given, use the
    default.

    Ex: Simple search
      GET /$ /my_index/_search?q=query+string
      {...}

    Ex: Create an index
      GET /$ PUT /my_new_index
      {...}

      or

      GET /$ put
      PUT /$ my_new_index
      {...}

#{shell.scope.help}
HELP
      end
      
    end
  end
end


