module Elasticshell

  module Scopes

    class Cluster < Scope

      def initialize options={}
        super("/_cluster", options)
      end

      def self.requests
        @requests = {
          "GET" => 
          {
            'health'  => "Retreive the health of the cluster.",
            'state'   => "Retreive the state of the cluster.",
            'settings'=> "Retreive the settings for the cluster.",
          }
        }
      end

      def exists?
        true
      end
      
    end
  end
end

  
