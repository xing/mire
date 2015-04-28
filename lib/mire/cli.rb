module Mire
  # Command line interface for mire
  class CLI
    def initialize
      @cli = OptionParser.new do |opts|
        opts.banner = 'Usage: bin/mire [options]'

        opts.on('-a', '--analyze', 'analyze ruby project') do
          analyzer = Analyzer.new
          puts 'Analyzing project'
          analyzer.run
          analyzer.save
        end

        opts.on('-c', '--check TERM', 'Check term and find usages') do |f|
          puts "Checking term #{f}"
          occurrence = Output::Occurrence.new
          puts occurrence.check(f)
        end

        opts.on('-u', '--unued', 'Check for unused methods') do
          puts 'Checking for unused methods'
          occurrence = Output::Unused.new
          puts occurrence.check
        end

        opts.on('-i', '--init', 'Create initial configuration file') do
          begin
            Mire::Configuration.copy_example
            puts "Configuration file #{Mire::Configuration::FILE} created"
          rescue Mire::Configuration::ExistingFile
            puts "Existing #{Mire::Configuration::FILE} file found - nothing done"
          end
        end
      end

      def run
        @cli.parse!
      end
    end
  end
end
