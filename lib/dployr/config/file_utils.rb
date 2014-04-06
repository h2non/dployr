require 'yaml'

module Dployr
  module Config
    module FileUtils

      FILENAME = 'Dployfile'
      EXTENSIONS = [ 'rb', 'yml', 'yaml' ]

      module_function

      def read_yaml(file_path)
        YAML.load_file file_path
      end

      def discover(dir = Dir.pwd)
        file_name = FILENAME
        (0..5).each do |n|
          [nil].concat(EXTENSIONS).each do |ext|
            file_name = FILENAME
            file_name += ".#{ext}" if ext
            file_path = File.join dir, ('../' * n), file_name
            return File.expand_path file_path, dir if File.exists? file_path
          end
        end
        nil
      end

    end
  end
end
