require 'elasticshell/scopes'

module Elasticshell

  module Scopes

    class Global < Scope

      def initialize options={}
        super("/", options)
      end

      def self.requests
        @requests ||= {
          "GET" => {
            '_status'  => "Retreive the status of all indices in the cluster."
          }
        }
      end

      def initial_scopes
        ['_cluster', '_nodes']
      end

      def fetch_scopes
        self.stat  
        self.scopes += client.safely(:get, {:index => '_status'}, :return => {"indices" => {}}, :log => false)["indices"].keys
      end

      def index name, options={}
        Scopes.index(name, options, :client => client)
      end

      def exists?
        true
      end
      
    end
  end
end

  
