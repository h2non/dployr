require 'yaml'
require 'dployr/config/constants'

module Dployr
  module Config
    module FileUtils

      include Dployr::Config::Constants

      module_function

      def yaml_file?(str)
        !(str =~ /\.y[a]?ml$/).nil?
      end

      def read_yaml(file_path)
        YAML.load_file file_path
      end

      def discover(dir = Dir.pwd)
        [nil].concat(EXTENSIONS).each do |ext|
          (0..5).each do |n|
            FILENAMES.each do |file|
              file += ".#{ext}" if ext
              file_path = File.join dir, ('../' * n), file
              puts file_path
              if File.file? file_path
                return File.expand_path file_path, dir
              end
            end
          end
        end
        return nil
      end

    end
  end
end
