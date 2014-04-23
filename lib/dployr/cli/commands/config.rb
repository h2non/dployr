require 'logger'
require 'dployr'
require 'dployr/cli/utils'

module Dployr
  module CLI
    class Config

      include Dployr::CLI::Utils

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attributes = parse_attributes @options[:attributes]

        begin
          create
          render_file
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      def create
        begin
          @dployr = Dployr::Init.new @attributes
          @dployr.load_config @options[:file]
        rescue Exception => e
          raise "Cannot load the config: #{e}"
        end
      end

      def render_file
        raise "Dployrfile was not found" if @dployr.file_path.nil?
        raise "Configuration is missing" unless @dployr.config.exists?
        begin
          if @name
            config = @dployr.config.get_config @name, @attributes
          else
            config = @dployr.config.get_config_all @attributes
          end
          unless config.nil?
            puts config.to_yaml
          else
            @log.info "Missing configuration data"
          end
        rescue Exception => e
          raise "Cannot generate the config: #{e}"
        end
      end

    end
  end
end
