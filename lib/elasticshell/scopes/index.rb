require 'elasticshell/scopes'
require 'elasticshell/utils/has_name'

module Elasticshell

  module Scopes

    class Index < Scope

      include HasName

      def initialize name, options={}
        self.name = name
        super("/#{self.name}", options)
      end

      def self.requests
        @requests ||= {
          "GET" => {
            "_aliases" => "Find the aliases for this index.",
            "_status"  => "Retrieve the status of this index.",
            "_stats"   => "Retrieve usage stats for this index.",
            "_search"  => "Search records within this index.",
          }
        }
      end

      def global
        @global ||= Scopes.global(:client => client)
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
        self.scopes += (client.safely(:get, {:index => name, :op => '_mapping'}, :return => { name => {}}, :log => false)[name] || {}).keys
      end

      def mapping mapping_name, options={}
        Scopes.mapping(self.name, mapping_name, options.merge(:client => client))
      end

    end
  end
end
