require 'dployr/commands/base'

module Dployr
  module Commands
    class Config < Base

      def initialize(options)
        super options
        begin
          create
          render_file
        rescue Exception => e
          @log.error e
          exit 1
        end
      end

      def render_file
        raise "Dployrfile was not found" if @dployr.file_path.nil?
        raise "Configuration is missing" unless @dployr.config.exists?
        begin
          if @name and options[:provider] and options[:region]
            config = get_region_config options
          elsif @name
            config = @dployr.config.get_config @name, @attrs
          else
            config = @dployr.config.get_config_all @attrs
          end
          unless config.nil?
            puts @options.to_yaml
            puts config.to_yaml
          else
            @log.info "Missing configuration data"
          end
        rescue Exception => e
          puts e.backtrace
          raise "Cannot generate the config: #{e}"
        end
      end

    end
  end
end
