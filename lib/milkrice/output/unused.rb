module Milkrice
  module Output
    class Unused < Base
      def check
        h = []
        invocations.each do |_key, is|
          is.each do |i|
            method = i['method']
            h << i['scope'] unless method.nil? || invocations[method]
          end
        end
        puts h.uniq.sort
      end
    end
  end
end
