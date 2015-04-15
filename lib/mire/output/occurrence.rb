module Mire
  module Output
    # checks for a term and print out the occurrences and the occurrences of
    # this and so on
    class Occurrence < Base
      def check(term, levels: 2, indenting: 0)
        return unless methods[term]
        methods[term]['invocations'].each do |method|
          puts "#{' ' * indenting * 2}#{location(method)}"

          next unless levels > 0
          check(method['method'], levels: levels - 1,
                                  indenting: indenting + 1)
        end
      end
    end
  end
end
