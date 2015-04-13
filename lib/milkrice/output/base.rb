module Milkrice
  module Output
    # base class of output classes
    class Base
      protected

      def invocations
        @invocations ||= JSON.parse(IO.read(Milkrice::Analyzer::FILE))
      end
    end
  end
end
