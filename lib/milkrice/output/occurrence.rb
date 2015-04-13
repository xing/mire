module Milkrice
  module Output
    class Occurrence
      def initialize
      end

      # check for a term
      def check(term, levels: 5, ident: '  ')
        return unless invokations[term]
        invokations[term].each do |invokation|
          puts "#{ident}#{invokation['scope']}  (#{invokation['file']}:#{invokation['line']})"
          check(invokation['method'], levels: levels - 1, ident: "#{ident}  ") if levels > 0
        end
      end

      private

      def invokations
        JSON.parse(IO.read(Milkrice::Analyzer::FILE))
      end
    end
  end
end
