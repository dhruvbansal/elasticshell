module Elasticshell
  module Commands
    class Help < Command

      def self.matches? input
        input =~ /^help/i
      end

      def long?
        input =~ /help +help/i
      end

      def evaluate!
        if long?
          shell.print <<HEADER

INTRODUCTION

Elasticshell wraps Elasticsearch's HTTP REST API with a convenient
command-line shell.

Elasticshell will try by default to connect to a locally running copy
of Elasticsearch on its default port (9200) when it starts up.  If
Elasticshell cannot connect on startup, it will print an error
message.  You can make Elasticshell connect to a different set of
servers using the `connect' command below.

COMMANDS
HEADER
        end
        shell.print <<HELP

  pwd
    Print the current scope.

  connect [SERVER[,SERVER]...]
    Connect to the given list of comma-separated Elasticseach servers.

  ls
    Show what common requests or child scopes are within the
    current scope. Try `ll' for a long listing.

  cd [SCOPE]
    Change to the given scope.  Current scope is reflected in the
    prompt (it's `#{shell.scope.path}' right now).

  [get|post|put|delete]
    Set the default HTTP verb (currently `#{shell.verb}').

  df
    Show a brief listing of disk usage by index.

  help
    Show contextual help.  Try `help help' for even more detail.

  [VERB] PATH[?QUERY] [BODY]
    Send an HTTP request using the given VERB to the given PATH, including
    QUERY string and BODY if given.  BODY can be the name of a local file on
    disk or `-' to read from STDIN.  If no verb is given, use the default
    verb (currently `#{shell.verb}').

HELP
        shell.print("Try `help help' for more detailed help with examples.") unless long?
        if long?
          shell.print <<FOOTER

EXAMPLES
          TBD.
FOOTER
        end
      end
      
    end
  end
end


