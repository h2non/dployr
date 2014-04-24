require 'logger'
require 'dployr'
require 'dployr/cli/utils'
require 'json'

module Dployr
  module CLI
    class Start

      include Dployr::CLI::Utils

      def initialize(options)
        @options = options
        @name = options[:name]
        @provider = options[:provider]
        @region = options[:region]
        @log = Logger.new STDOUT
        
        begin
          if @name
            config = create.config.get_region(@name, @provider, @region)
          else
            raise "No template name specified"
          end
          instance = Dployr::Commands::Start.new(config, options)
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
