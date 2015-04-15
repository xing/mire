module Mire
  module Output
    # Check for unused methods
    class Unused < Base
      def check
        methods
          .select { |_, m| m[:invocations].empty? }
          .map { |_, m| m[:definitions].map { |d| location(d) } }
          .flatten
          .sort
      end
    end
  end
end
