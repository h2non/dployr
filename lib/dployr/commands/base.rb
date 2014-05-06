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

      attr_reader :options, :name, :log, :attrs, :dployr

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attrs = parse_attributes @options[:attributes]
        if !options[:public_ip]
          options[:public_ip] = false
        end
        @provider = options[:provider].upcase
        create
        @config = get_region_config options
        @p_attrs = @config[:attributes]
      end

      def create
        begin
          @dployr = Dployr::Init.new @attrs
          @dployr.load_config @options[:file]
        rescue Exception => e
          raise "Cannot load the config: #{e}"
        end
      end

      def create_compute_client
        begin
          Dployr::Compute.const_get(@provider.to_sym).new @regions
        rescue Exception => e
          raise "Provider '#{@provider}' is not supported: #{e}"
        end
      end

      def get_region_config(options)
        @dployr.config.get_region options[:name], options[:provider], options[:region]
      end

    end
  end
end
