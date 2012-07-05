require 'elasticshell/scopes'

module Elasticshell

  module Scopes

    class Mapping < Scope

      VALID_MAPPING_NAME_RE = %r![^/]!

      attr_accessor :index

      def initialize index, name, options={}
        self.index = index
        self.name  = name
        super("/#{index.name}/#{self.name}", options)
      end

      attr_reader :name
      def name= name
        raise ArgumentError.new("Invalid mapping name: '#{name}'") unless name =~ VALID_MAPPING_NAME_RE
        @name = name
      end

      def commands
        {
          "_search"  => "Search records within this mapping.",
          "_mapping" => "Retrieve the mapping settings for this mapping.",
        }
      end

      def exists?
        index.refresh
        index.contents.include?(name)
      end

      def command? command
        true
      end

      def execute command, shell
        case
        when command?(command)
          shell.request(:get, :index => index.name, :type => name)
        else
          record = shell.request(:get, :index => index.name, :type => name)
          shell.print(record) if record
        end
      end
      
    end
  end
end

  
