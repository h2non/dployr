require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class Execute

      include Dployr::Utils

      def initialize(options, stages)
        begin
          @log = Logger.new STDOUT
          @name = config[:attributes]["name"]
          @provider = options[:provider].upcase
          @region = options[:region]
          @attributes = config[:attributes]

          puts "Connecting to #{@provider}...".yellow
          @client = create_compute_client

          puts "Looking for #{@name} in #{@region}...".yellow
          @ip = @client.get_ip @name
          if @ip
            puts "#{@name} found with IP #{@ip}".yellow
          else
            raise "#{@name} not found"
          end

          stages.each do |stage|
            Dployr::Scripts::Hook.new @ip, config, stage
          end
        rescue Exception => e
          @log.error e
          exit 1
        end
      end

      private

      def create_compute_client
        begin
          Dployr::Compute.const_get(@provider.to_sym).new @regions
        rescue Exception => e
          raise "Provider '#{@provider}' is not supported: #{e}"
        end
      end

    end
  end
end
