module Mire
  module Output
    # Check for unused methods
    class Unused < Base
      def check
        methods
          .select { |_, m| m[:invocations].empty? }
          .map { |_, m| definitions(m[:definitions]) }
          .flatten
          .compact
          .sort
      end

      private

      def definitions(definitions)
        definitions.map do |d|
          location(d) unless excluded_file?(d[:file])
        end
      end

      def excluded_file?(file)
        excluded_files.any? { |e| File.fnmatch(e, file, File::FNM_PATHNAME) }
      end

      def excluded_files
        @excluded_files ||=
          configuration.read(:output, :unused, :excluded_files) || []
      end
    end
  end
end
