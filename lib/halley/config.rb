require 'yaml'

module Halley
  module Config

    def read file_path
      YAML.load_file file_path
    end

    module_function :read

  end
end
