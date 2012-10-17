module Elasticshell
  module Spec
    class FakeOutput

      def initialize
        @buffer = ''
      end

      def write s
        @buffer += s
      end

      def puts s
        write(s + "\n")
      end

      def read
        @buffer
      end

      def gets arg
      end
      
    end
  end
end

