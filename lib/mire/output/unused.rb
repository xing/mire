module Mire
  module Output
    # Check for unused methods
    class Unused < Base
      def check
        methods
          .select { |_, m| m[:invocations].empty? }
          .map { |_, m| location(m[:definition]) }
          .sort
      end
    end
  end
end
