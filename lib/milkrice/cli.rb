module Milkrice
  class CLI
    def initialize
      @cli = OptionParser.new do |opts|
        opts.banner = 'Usage: parse.rb [options]'

        opts.on('-a', '--analyze', 'analyze RAILS project') do
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
      end

      def run
        @cli.parse!
      end
    end
  end
end
