module Elasticshell
  module RecognizesVerb

    VERB_RE = "(?:HEAD|GET|PUT|POST|DELETE)"

    def verb_re
      RecognizesVerb::VERB_RE
    end

    def canonicalize_verb v
      case v.to_s
      when /^G/i  then "GET"
      when /^PO/i then "POST"
      when /^PU/i then "PUT"
      when /^D/i  then "DELETE"
      when /^H/i  then "HEAD"
      end
    end
    
    def is_http_verb? s
      s =~ Regexp.new("^" + verb_re + "$", true)
    end
    
  end
end
