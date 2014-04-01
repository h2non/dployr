require 'yaml'

module Halley
  module Config

    FILENAME = 'Halleyfile'

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

    module_function :read_yaml, :discover

  end
end
