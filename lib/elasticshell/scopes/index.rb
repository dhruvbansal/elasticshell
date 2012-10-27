module Elasticshell

  module Scopes

    class Index < Scope

      include HasName

      attr_reader :mappings

      def initialize name, options={}
        self.name = name
        @mappings = []
        super("/#{self.name}", options)
      end

      def self.requests
        @requests ||= {
          "GET" => {
            "_aliases" => "Find the aliases for this index.",
            "_status"  => "Retrieve the status of this index.",
            "_stats"   => "Retrieve usage stats for this index.",
            "_search"  => "Search records within this index.",
            "_count"   => "Count records within this index."
          }
        }
      end

      def global
        @global ||= Scopes.global(:client => client)
      end

      def status
        @status ||= client.safely(:get, {:index => name, :op => '_status'}, :return => {"indices" => {name => {}}}, :log => false)
      end
      
      def reset!
        @status   = nil
        @mappings = []
        super()
      end
      
      def exists?
        return false unless client.connected?
        global.refresh
        global.scopes.include?(name)
      end

      def multi?
        name.include?(',')
      end

      def single?
        ! multi?
      end

      def fetch_scopes
        @mappings = (client.safely(:get, {:index => name, :op => '_mapping'}, :return => { name => {}}, :log => false)[name] || {}).keys
        self.scopes += @mappings
      end

      def mapping mapping_name, options={}
        Scopes.mapping(self.name, mapping_name, options.merge(:client => client))
      end

    end
  end
end
