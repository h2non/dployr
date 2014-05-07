require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class StopDestroy < Base

      def initialize(options, action)
        super options
        @action = action

        puts "Connecting to #{@provider}...".yellow
        @client = Dployr::Compute.const_get(@provider.to_sym).new(@options, @p_attrs)

        puts "Looking for #{@p_attrs["name"]} in #{@options[:region]}...".yellow
        @ip = @client.get_ip
        if @ip
          puts "#{@p_attrs["name"]} found with IP #{@ip}".yellow
        else
          puts "#{@p_attrs["name"]} not found".yellow
        end

        Dployr::Scripts::Default_Hooks.new @ip, @config, action, self
      end

      def action
        puts "#{@action.capitalize}ing #{@p_attrs["name"]} in #{@options[:region]}...".yellow
        @client.send(@action.to_sym)
        puts "#{@p_attrs["name"]} #{@action}ed sucesfully".yellow
        @ip
      end

    end
  end
end
