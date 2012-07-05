require 'elasticshell/scopes'

module Elasticshell

  module Scopes

    class Global < Scope

      def initialize options={}
        super("/", options)
      end

      def commands
        {
          '_status'  => "Retreive the status of all indices in the cluster."
        }
      end

      def initial_contents
        ['_cluster', '_nodes']
      end

      def fetch_contents
        self.contents += client.safely(:get, {:index => '_status'}, :return => {"indices" => {}})["indices"].keys
      end

      def index name, options={}
        Scopes.index(name, options, :client => client)
      end

      def exists?
        true
      end

      def execute command, shell
        case
        when command =~ /^_cluster/
          shell.scope = Scopes.cluster(:client => client)
        when command =~ /^_nodes/
          shell.scope = Scopes.nodes(:client => client)
        when command?(command)
          shell.request(:get)
        when index_names.include?(command)
          shell.scope = index(command)
        else
          super(command, shell)
        end
      end
      
    end
  end
end

  
