module Mire
  module Output
    # checks for a term and print out the occurrences and the occurrences of
    # this and so on
    class Occurrence < Base
      def check(term, levels: 2, indenting: 0, output: [])
        term = term.to_sym if term
        return unless methods[term]
        methods[term][:invocations].each_with_object(output) do |method, o|
          o << "#{' ' * indenting * 2}#{location(method)}"

          next unless levels > 0
          check(method[:method], levels: levels - 1,
                                 indenting: indenting + 1,
                                 output: o)
        end
        output
      end
    end
  end
end
