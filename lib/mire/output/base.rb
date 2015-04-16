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
        [location_file(location), location_method(location)]
          .reject { |s| s.to_s.empty? }
          .join(' ')
      end

      private

      def location_method(location)
        [location[:class], location[:method]]
          .reject { |s| s.to_s.empty? }
          .join('.')
      end

      def location_file(location)
        [location[:file], location[:line]]
          .reject { |s| s.to_s.empty? }
          .join(':')
      end
    end
  end
end
