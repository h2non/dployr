require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Commands
    class Stop_Destroy

      include Dployr::Utils

      def initialize(config, options, action)
        begin
          @log = Logger.new STDOUT     
          @name = config[:attributes]["name"]
          @provider = options[:provider].upcase
          @region = options[:region]
          @attributes = config[:attributes]
          @action = action
          
          puts "Connecting to #{@provider}...".yellow
          @client = Dployr::Compute.const_get(@provider.to_sym).new(@region)
          
          puts "Looking for #{@name} in #{@region}...".yellow
          @ip = @client.get_ip(@name)
          if @ip
            puts "#{@name} found with IP #{@ip}".yellow
          else
            puts "#{@name} not found".yellow
          end
              
          Dployr::Scripts::Default_Hooks.new @ip, config, @action, self
          
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
      
      def action        
        puts "#{@action.capitalize}ing #{@name} in #{@region}...".yellow
        @client.send(@action.to_sym, @name) 
        puts "#{@name} destroyed sucesfully".yellow
        return @ip
      end
      
    end
  end
end
