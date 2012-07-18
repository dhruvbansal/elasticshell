module Elasticshell
  module HasName

    NAME_RE = %r![^/]!

    attr_reader :name

    def name= new_name
      raise ArgumentError.new("Invalid index name: '#{new_name}'") unless new_name =~ NAME_RE
      @name = new_name
    end
    
  end
end
