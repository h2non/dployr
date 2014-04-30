require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class StopDestroy < Base

      def initialize(options, action)
        super options
        begin
          create
          config = get_region_config options

          @name = config[:attributes]["name"]
          @provider = options[:provider].upcase
          @region = options[:region]
          @attributes = config[:attributes]
          @action = action

          puts "Connecting to #{@provider}...".yellow
          @client = Dployr::Compute.const_get(@provider.to_sym).new @region

          puts "Looking for #{@name} in #{@region}...".yellow
          @ip = @client.get_ip(@name, options[:public_ip])
          if @ip
            puts "#{@name} found with IP #{@ip}".yellow
          else
            puts "#{@name} not found".yellow
          end

          Dployr::Scripts::Default_Hooks.new @ip, config, action, self
        rescue Exception => e
          @log.error e
          exit 1
        end
      end

      def action
        puts "#{@action.capitalize}ing #{@name} in #{@region}...".yellow
        @client.send(@action.to_sym, @name)
        puts "#{@name} #{@action}ed sucesfully".yellow
        @ip
      end

    end
  end
end
