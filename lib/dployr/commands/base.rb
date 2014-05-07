require 'logger'
require 'dployr/init'
require 'dployr/commands/utils'
require 'dployr/compute/aws'
require 'dployr/compute/gce'
require 'dployr/compute/baremetal'

module Dployr
  module Commands
    class Base

      include Dployr::Commands::Utils

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attrs = parse_attributes @options[:attributes]
        @options[:public_ip] = false if !options[:public_ip]
        @provider = options[:provider].upcase
        create
        get_config
      end

      def create
        begin
          @dployr = Dployr::Init.new @attrs
          @dployr.load_config @options[:file]
        rescue => e
          raise "Cannot load the config: #{e}"
        end
      end

      def create_compute_client
        begin
          Dployr::Compute.const_get(@provider.to_sym).new @regions
        rescue => e
          raise "Provider '#{@provider}' is not supported: #{e}"
        end
      end

      def get_region_config(options)
        @dployr.config.get_region options[:name], options[:provider], options[:region]
      end

      private

      def get_config
        @config = get_region_config @options
        @p_attrs = @config[:attributes]
      end

    end
  end
end
