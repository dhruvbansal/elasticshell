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
      raise ClientError.new("Not connected to any Elasticsearch servers.") unless shell.connected?
    end

    def evaluate!
      raise NotImplementedError.new("Define the 'evaluate!' instance method in your subclass of #{self.class}")
    end
  end

  module Commands
    PRIORITY = [].tap do |priority|
      %w[cd pwd df connect help ls pretty set_verb blank request unknown].each do |command_name|
        klass_name = command_name.split("_").map(&:capitalize).join("")
        autoload klass_name.to_sym, "elasticshell/commands/#{command_name}"
        priority << klass_name
      end
    end
  end

end
