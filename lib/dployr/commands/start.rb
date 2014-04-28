require 'logger'
require 'dployr/commands/base'
require 'dployr/compute/aws'
require 'dployr/compute/gce'
require 'colorize'


module Dployr
  module Commands
    class Start < Base

      def initialize(options)
        super options
        begin
          create
          config = get_region_config options

          @name = config[:attributes]["name"]
          @provider = options[:provider].upcase
          @region = options[:region]

          puts "Connecting to #{@provider}...".yellow
          @client = Dployr::Compute.const_get(@provider.to_sym).new @region

          puts "Looking for #{@name} in #{@region}...".yellow
          @ip = @client.get_ip @name

          Dployr::Scripts::Default_Hooks.new @ip, config, "start", self
        rescue Exception => e
          @log.error e
          exit 1
        end
      end

      def action
        if @ip
          puts "#{@name} found with IP #{@ip}".yellow
        else
          @ip = @client.start @attributes, @region
          puts "Startded instance for #{@name} in #{@region} with IP #{@ip} succesfully".yellow
        end
        @ip
      end

    end
  end
end
