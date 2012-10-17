module Elasticshell
  module HasVerb

    VERBS = %w[HEAD GET POST PUT DELETE]

    def verb
      @verb ||= "GET"
    end

    def verb= new_verb
      @verb = new_verb.to_s.upcase if VERBS.include?(new_verb.to_s.upcase)
    end
    
  end
end
