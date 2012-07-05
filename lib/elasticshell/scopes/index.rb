require 'elasticshell/scopes'

module Elasticshell

  module Scopes

    class Index < Scope

      VALID_INDEX_NAME_RE = %r![^/]!

      def initialize name, options={}
        self.name = name
        super("/#{self.name}", options)
      end

      attr_reader :name
      def name= name
        raise ArgumentError.new("Invalid index name: '#{name}'") unless name =~ VALID_INDEX_NAME_RE
        @name = name
      end

      def commands
        {
          "_aliases" => "Find the aliases for this index.",
          "_status"  => "Retrieve the status of this index.",
          "_stats"   => "Retrieve usage stats for this index.",
          "_search"  => "Search records within this index.",
        }
      end

      def global
        @global ||= Scopes.global(:client => client)
      end

      def exists?
        global.refresh
        global.contents.include?(name)
      end

      def fetch_contents
        @contents = (client.safely(:get, {:index => name, :op => '_mapping'}, :return => { name => {}})[name] || {}).keys
      end

      def mapping mapping_name, options={}
        Scopes.mapping(self.name, mapping_name, options.merge(:client => client))
      end

      def execute command, shell
        case
        when command?(command)
          shell.request(:get, :index => name)
        when mapping_names.include?(command)
          shell.scope = mapping(command)
        else
          super(command, shell)
        end
      end

    end
  end
end
