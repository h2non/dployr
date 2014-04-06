module Dployr
  module Config
    module Create

      FILENAME = 'Dployrfile'

      RB_CONTENT = <<-EOS
      Dployr::configure do |dployr|
        dployr.config.set_default({
          attributes: {
            instance_type: "m1.medium"
          }
        })

        dployr.config.add_instance('name', {
          scripts: [
            { path: 'path/to/script.sh' }
          ]
        })
      end
      EOS

      YAML_CONTENT = <<-EOS
      default:
        attributes:
          instance_type: m1.medium
      instance:
        attributes:
          name: my_instance
        scripts:
          -
            path: path/to/script.sh
      EOS

      module_function

      def write_file(dir = Dir.pwd, type = 'rb')
        yaml = type == 'yaml'
        file_name = FILENAME
        file_name += ".yaml" if yaml
        content = yaml ? YAML_CONTENT : RB_CONTENT
        begin
          file = File.open "#{dir}/#{FILENAME}", "w"
          file.write content
        rescue IOError => e
          raise e
        ensure
          file.close unless file == nil
        end
      end

    end
  end
end
