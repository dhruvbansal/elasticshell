module Elasticshell

  module Scopes

    class Nodes < Scope

      def initialize options={}
        super("/_nodes", options)
      end

      def self.requests
        @requests ||= {
          "GET" => {
            'info'  => "Retreive info about the cluster's nodes.",
            'stats' => "Retreive stats for the cluter's nodes.",
          }
        }
      end

      def exists?
        true
      end
      
    end
  end
end

  
