require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Commands
    class Start

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
         
          Dployr::Scripts::Default_Hooks.new @ip, config, "start", self
         
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
      
      def action
        if @ip
          puts "#{@name} found with IP #{@ip}".yellow
        else
          @ip = @client.start(@attributes, @region)
          puts "Startded instance for #{@name} in #{@region} with IP #{@ip} succesfully".yellow
        end
        return @ip
      end
      
    end
  end
end
