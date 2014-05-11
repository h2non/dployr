require 'dployr/commands/base'

module Dployr
  module Commands
    class Start < Base

      def initialize(options)
        super options

        puts "Connecting to #{@provider}...".yellow
        @client = Dployr::Compute.const_get(@provider.to_sym).new @options, @p_attrs

        if @p_attrs["type"] == "network"
          puts "Creating network in #{@options[:provider]}: #{@options[:region]}...".yellow
          @network = @client.create_network(@p_attrs["name"], @p_attrs["private_net"], @p_attrs["firewalls"], [])
        else
          puts "Looking for #{@p_attrs["name"]} in #{@options[:region]}...".yellow
          @ip = @client.get_ip

          Dployr::Scripts::Default_Hooks.new @ip, @config, "start", self
        end
      end

      def action
        if @ip
          puts "#{@name} found with IP #{@ip}".yellow
        else
          @ip = @client.start
          puts "Startded instance for #{@p_attrs["name"]} in #{@options[:region]} with IP #{@ip} succesfully".yellow
        end
        @ip
      end

    end
  end
end
