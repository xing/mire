module Mire
  # Command line interface for mire
  class CLI
    class << self
      def parse # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        slop = Slop.parse do |opts|
          opts.on('-h', '--help', 'Show this help') do
            puts opts
            exit
          end
          opts.on('-a', '--analyze', 'Analyze ruby project') do
            analyze
            exit
          end
          opts.on('-c', '--check TERM', 'Check term and find usages') do |f|
            check(f)
            exit
          end
          opts.on('-u', '--unused', 'Check for unused methods') do
            unused
            exit
          end
          opts.on('-i', '--initialize', 'Create initial configuration file') do
            init
            exit
          end
        end

        puts slop
      rescue Slop::UnknownOption
        puts 'Unknown option - use --help to see all options'
      end

      private

      def init
        Mire::Configuration.copy_example
        puts "Configuration file #{Mire::Configuration::FILE} created"
      rescue Mire::Configuration::ExistingFile
        puts "Existing #{Mire::Configuration::FILE} file found - nothing done"
      end

      def analyze
        analyzer = Analyzer.new
        puts 'Analyzing project'
        analyzer.run
        analyzer.save
      end

      def check(f)
        puts "Checking term #{f}"
        occurrence = Output::Occurrence.new
        puts occurrence.check(f)
      end

      def unused
        puts 'Checking for unused methods'
        occurrence = Output::Unused.new
        puts occurrence.check
      end
    end
  end
end
