module Mire
  # Command line interface for mire
  class CLI
    class << self
      METHODS = [
        [:analyze, 'Analyze ruby project'],
        [:check,   'Check term and find usages', arguments: [:term]],
        [:unused,  'Check for unused methods'],
        [:init,    'Create initial configuration file'],
        [:help,    'Show this help']
      ]

      def parse
        return help unless ARGV[0]
        fail UnknownCommand if unknown_command?

        METHODS.each do |command, _description, _config|
          next unless options(command).include?(ARGV[0])
          arguments = ARGV
          arguments.shift
          send(command, *arguments)
        end
      rescue UnknownCommand
        puts "Unknown command Argument.\n\n"
        help
      rescue MissingArgument
        puts "Missing Argument.\n\n"
        help
      end

      private

      def unknown_command?
        METHODS.none? { |command, _, _| options(command).include?(ARGV[0]) }
      end

      def help
        puts "Usage:\n  mire [option]\n\n"
        puts 'Options:'

        METHODS.each do |command, description, config|
          config ||= {}
          arguments = config[:arguments] || []
          opts = "#{options(command).join(', ')} #{arguments.join(' ').upcase}"
          puts "  #{opts}#{' ' * (25 - opts.length)}#{description}"
        end
      end

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

      def check(f = nil)
        fail MissingArgument unless f
        puts "Checking term #{f}"
        occurrence = Output::Occurrence.new
        puts occurrence.check(f)
      end

      def unused
        puts 'Checking for unused methods'
        occurrence = Output::Unused.new
        puts occurrence.check
      end

      def options(command)
        ["-#{command[0]}", "--#{command}"]
      end
    end

    class MissingArgument < Exception; end
    class UnknownCommand < Exception; end
  end
end
