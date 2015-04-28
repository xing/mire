module Mire
  # load configuration
  class Configuration
    FILE = '.mire.yml'

    class << self
      def copy_example
        fail ExistingFile if File.exist?(FILE)
        FileUtils.cp(example_file, FILE)
      end

      private

      def example_file
        File.join(File.dirname(__FILE__), 'configuration_example.yml')
      end
    end

    def initialize
      @config = if File.exist?(FILE)
                  symbolize_keys(YAML.load_file(FILE))
                else
                  {}
                end
    end

    def read(*args)
      args.reduce(@config) do |c, key|
        return nil unless c
        c[key]
      end
    end

    private

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value.is_a?(Hash) ? symbolize_keys(value) : value
      end
    end

    class ExistingFile < StandardError; end
  end
end
