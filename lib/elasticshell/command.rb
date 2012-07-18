module Elasticshell

  class Command

    attr_accessor :shell, :input

    def initialize shell, input
      self.shell = shell
      self.input = input
    end

    def self.matches? input
      raise NotImplementedError.new("Define the 'matches?' method on #{self.class}")
    end

    def be_connected!
      raise ClientError.new("Not connected to any Elasticsearch servers.") unless shell.client.connected?
    end

    def evaluate!
      raise NotImplementedError.new("Define the 'evaluate!' instance method in your subclass of #{self.class}")
    end
  end

  Dir[File.join(File.dirname(__FILE__), '**/*.rb')].each { |path| require path }

  module Commands
    PRIORITY = [Cd, Pwd, Connect, Help, Ls, Pretty, SetVerb, Blank, Request, Unknown]
  end

end



