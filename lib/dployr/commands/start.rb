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
          provider = Dployr::Compute.const_get(@provider.to_sym).new(@region)
                 
          puts "Looking for #{@name} in #{@region}...".yellow
          @ip = provider.get_ip(@name)
          
          if @ip
            puts "#{@name} found with IP #{@ip}".yellow
          else
            puts "Creating new instance for #{@name} in #{@region}...".yellow
            @ip = provider.start(@attributes, @region)
            puts "Created new instance for #{@name} in #{@region} with IP #{@ip}".yellow
          end
         
          Dployr::Scripts::Default_Hooks.new @ip, config, "start"
         
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end
