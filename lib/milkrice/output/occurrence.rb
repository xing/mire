module Milkrice
  module Output
    # checks for a term and print out the occurrences and the occurrences of
    # this and so on
    class Occurrence < Base
      def check(term, levels: 2, indenting: 0)
        return unless invocations[term]
        invocations[term].each do |invocation|
          puts render_invocation(invocation, indenting)

          next unless levels > 0
          check(invocation['method'], levels: levels - 1,
                                      indenting: indenting + 1)
        end
      end

      private

      def render_invocation(invocation, indenting)
        [
          ' ' * indenting * 2,
          invocation['scope'],
          " (#{invocation['file']}:#{invocation['line']})"
        ].join
      end
    end
  end
end
