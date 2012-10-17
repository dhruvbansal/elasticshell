module Elasticshell

  module Scopes

    class Mapping < Scope

      include HasName

      attr_accessor :index

      def initialize index, name, options={}
        self.index = index
        self.name  = name
        super("/#{index.name}/#{self.name}", options)
      end

      def self.requests
        @requests ||= {
          "GET" => {
            "_search"  => "Search records within this mapping.",
            "_mapping" => "Retrieve the mapping settings for this mapping.",
          }
        }
      end

      def exists?
        index.refresh
        index.scopes.include?(name)
      end

    end
  end
end

  
