require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class Execute < Base

      def initialize(options, stages)
        super options

        puts "Connecting to #{@provider}...".yellow
        @client = Dployr::Compute.const_get(@provider.to_sym).new @options, @p_attrs

        puts "Looking for #{@name} in #{@region}...".yellow
        @ip = @client.get_ip
        if @ip
          puts "#{@p_attrs["name"]} found with IP #{@ip}".yellow
        else
          raise "#{@p_attrs["name"]} not found"
        end

        stages.each do |stage|
          Dployr::Scripts::Hook.new @ip, @config, stage
        end
      end

    end
  end
end
