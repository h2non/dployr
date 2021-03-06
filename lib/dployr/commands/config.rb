require 'dployr/commands/base'

module Dployr
  module Commands
    class Config < Base

      def initialize(options)
        super options
        render_file
      end

      private

      def render_file
        raise "Dployrfile was not found" if @dployr.file_path.nil?
        raise "Configuration is missing" unless @dployr.config.exists?
        print_config
      end

      def print_config
        if @name and @options[:provider] and @options[:region]
          config = get_region_config @options
        elsif @name
          config = @dployr.config.get_config @name, @attrs
        else
          config = @dployr.config.get_config_all @attrs
        end
        unless config.nil?
          puts @options.to_yaml
          puts config.to_yaml
        else
          raise "Missing configuration data"
        end
      end

    end
  end
end
