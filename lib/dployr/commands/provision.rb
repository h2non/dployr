require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Commands
    class Provision

      include Dployr::Utils

      def initialize(config, options)
        begin
          @log = Logger.new STDOUT     
          @name = config[:attributes]["name"]
          @provider = options[:provider].upcase
          @region = options[:region]
          @attributes = config[:attributes]

          puts "Connecting to #{@provider}...".yellow
          @client = Dployr::Compute.const_get(@provider.to_sym).new(@region)
          
          puts "Looking for #{@name} in #{@region}...".yellow
          @ip = @client.get_ip(@name)
          if @ip
            puts "#{@name} found with IP #{@ip}".yellow
          else
            raise "#{@name} not found"
          end
          
          Dployr::Scripts::Default_Hooks.new @ip, config, "provision", self
          
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      def action
        return @ip
      end
    end
  end
end
