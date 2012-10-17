module Elasticshell

  module Scopes

    class Global < Scope

      attr_reader :indices

      def initialize options={}
        @indices = []
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

      def status
        @status ||= client.safely(:get, {:index => '_status'}, :return => {"indices" => {}}, :log => false)
      end

      def reset!
        @indices = []
        @status  = nil
        super()
      end

      def fetch_scopes
        @indices = status["indices"].keys
        self.scopes += @indices
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

  
