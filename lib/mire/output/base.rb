module Mire
  module Output
    # base class of output classes
    class Base
      protected

      def methods
        @methods ||= YAML.load_file(Mire::Analyzer::FILE)
      end

      def configuration
        @configuration ||= Mire::Configuration.new
      end

      def location(location)
        [location_method(location), location_file(location)].join
      end

      private

      def location_method(location)
        "#{location[:class]}.#{location[:method]}"
      end

      def location_file(location)
        " (#{location[:file]}:#{location[:line]})"
      end
    end
  end
end
