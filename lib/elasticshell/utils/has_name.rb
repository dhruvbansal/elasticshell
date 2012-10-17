module Elasticshell
  module HasName

    FORBIDDEN_NAME_CHARS = %r![/\s]!

    attr_reader :name

    def name= new_name
      raise ArgumentError.new("Invalid index name: '#{new_name}'") if new_name =~ FORBIDDEN_NAME_CHARS
      @name = new_name
    end
    
  end
end
