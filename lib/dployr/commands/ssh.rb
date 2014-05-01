require 'logger'
require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class Ssh < Base

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
          @ip = @client.get_ip(@name, options[:public_ip])
          if @ip
            puts "#{@name} found with IP #{@ip}".yellow
          else
            raise "#{@name} not found"
          end

          Dployr::Scripts::Ssh.new @ip, config

        rescue Exception => e
          self.log.error e
          exit 1
        end
      end

    end
  end
end
