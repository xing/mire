module Milkrice
  module Output
    # Check for unused methods
    class Unused < Base
      def check
        h = []
        invocations.each do |_key, is|
          is.each do |i|
            method = i['method']
            next if method.nil? ||
              Analyzer::BLACKLIST.include?(method.to_sym) ||
              invocations[method]
            h << i['scope']
          end
        end
        puts h.uniq.sort
      end
    end
  end
end
