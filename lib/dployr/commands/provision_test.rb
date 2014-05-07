require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class ProvisionTest < Base

      def initialize(options, action)
        super options

        puts "Connecting to #{@provider}...".yellow
        @client = Dployr::Compute.const_get(@provider.to_sym).new(@options, @p_attrs)

        puts "Looking for #{@p_attrs["name"]} in #{@options[:region]}...".yellow
        @ip = @client.get_ip
        if @ip
          puts "#{@p_attrs["name"]} found with IP #{@ip}".yellow
        else
          raise "#{@p_attrs["name"]} not found"
        end

        Dployr::Scripts::Default_Hooks.new @ip, @config, action, self
      end

      def action
        @ip
      end
    end
  end
end
