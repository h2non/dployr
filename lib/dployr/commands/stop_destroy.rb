require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class StopDestroy < Base

      def initialize(options, action)
        super options

        @action = action
        puts "Connecting to #{@provider}...".yellow
        @client = Dployr::Compute.const_get(@provider.to_sym).new @options, @p_attrs

        if @p_attrs["type"] == "network"
          puts "Destroying network in #{@options[:provider]}: #{@options[:region]}...".yellow
          @network = @client.delete_network(@p_attrs["name"], @p_attrs["private_net"], @p_attrs["firewalls"], [])          
        else
          puts "Looking for #{@p_attrs["name"]} in #{@options[:region]}...".yellow
          @ip = @client.get_ip
          if @ip
            puts "#{@p_attrs["name"]} found with IP #{@ip}".yellow
          else
            puts "#{@p_attrs["name"]} not found".yellow
          end

          Dployr::Scripts::Default_Hooks.new @ip, @config, action, self
        end

      end

      def action
        puts "#{@action.capitalize}ing #{@p_attrs["name"]} in #{@options[:region]}...".yellow
        @client.send @action.to_sym
        puts "#{@p_attrs["name"]} #{@action}ed sucesfully".yellow
        @ip
      end

    end
  end
end
