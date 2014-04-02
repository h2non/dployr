module Dployr
  module Config
    class File

      attr_reader :path

      FILENAME = 'Dployfile'

      def initialize(options)
        @path = discover options.path
        @load
      end

      private

      def load
        @path
      end

      def read_yaml(file_path)
        YAML.load_file file_path
      end

      def discover(dir = Dir.pwd)
        path = nil
        (0..5).each do |n|
          lookpath = File.join dir, ('../' * n), FILENAME
          if File.exists? lookpath
            path = File.expand_path lookpath, dir
            break
          end
        end
        path
      end

    end
  end
end
