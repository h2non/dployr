require 'logger'
require 'dployr'
require 'dployr/cli/utils'

module Dployr
  module CLI
    class Halt

      include Dployr::CLI::Utils

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attributes = parse_attributes @options[:attributes]

        begin
          if @name
            config = create.config.get_config @name
          else
            config = create.config.get_config_all
          end
          instance = Dployr::Commands::Stop_Destroy.new(config, options, "halt")
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      def create
        begin
          @dployr = Dployr::Init.new @attributes
          @dployr.load_config @options[:file]
          @dployr
        rescue Exception => e
          raise "Cannot load the config: #{e}"
        end
      end

    end
  end
end
