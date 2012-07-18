module Elasticshell
  module HasVerb

    # List of allowed HTTP verbs.
    VERBS = %w[HEAD GET POST PUT DELETE]

    attr_reader :verb

    def verb= new_verb
      raise ArgumentError.new("'#{new_verb}' is not a valid HTTP verb.  Must be one of: #{VERBS.join(', ')}") unless VERBS.include?(new_verb.to_s.upcase)
      @verb = new_verb.to_s.upcase
    end
    
  end
end
