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
          occurrence.check(f)
        end

        opts.on('-u', '--unued', 'Check for unused methods') do
          puts 'Checking for unused methods'
          occurrence = Output::Unused.new
          occurrence.check
        end
      end

      def run
        @cli.parse!
      end
    end
  end
end
