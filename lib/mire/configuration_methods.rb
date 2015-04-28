module Mire
  module ConfigurationMethods

    def configuration
      @configuration ||= Mire::Configuration.new
    end

    def excluded_file?(file)
      excluded_files.any? { |e| File.fnmatch(e, file, File::FNM_PATHNAME) }
    end
  end
end
