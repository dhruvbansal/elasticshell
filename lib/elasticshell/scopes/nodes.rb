require 'elasticshell/scopes'

module Elasticshell

  module Scopes

    class Nodes < Scope

      def initialize options={}
        super("/_nodes", options)
      end

      def commands
        {
          'info'  => "Retreive info about the cluster's ndoes.",
          'stats' => "Retreive stats for the cluter's nodes.",
        }
      end

      def exists?
        true
      end

      def execute command, shell
        case
        when command?(command)
          shell.request(:get, :index => '_nodes')
        else
          super(command, shell)
        end
      end
      
    end
  end
end

  
