require 'elasticshell/scopes'

module Elasticshell

  module Scopes

    class Cluster < Scope

      def initialize options={}
        super("/_cluster", options)
      end

      def commands
        {
          'health'  => "Retreive the health of the cluster.",
          'state'   => "Retreive the state of the cluster.",
          'settings'=> "Retreive the settings for the cluster.",
        }
      end

      def exists?
        true
      end

      def execute command, shell
        case
        when command?(command)
          shell.request(:get, :index => '_cluster')
        else
          super(command, shell)
        end
      end
      
    end
  end
end

  
