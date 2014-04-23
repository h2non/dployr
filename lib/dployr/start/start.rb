require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Start
    class Start

      include Dployr::Utils

      def initialize(config, options)
        begin
          @log = Logger.new STDOUT
          
          @name = config[:attributes]["name"]
          @provider = options[:provider]
          @region = options[:region]
          #@attributes = config[:providers][@provider]["regions"][@region]["attributes"]
          @attributes = config[:attributes]
          puts @attributes.inspect
          exit 0
          if @provider == "aws"  
            puts "Connecting to AWS...".yellow
            aws = Dployr::Compute::AWS.new(@region)
            
            puts "Looking for #{@name} in #{@region}...".yellow
            @ip = aws.get_ip(@name)
            
            if @ip
              puts "#{@name} found with IP #{@ip}".yellow
            else
              @ip = aws.start(@attributes, @region)
            end
          else
            raise "Unsopported provider #{options[:provider]}"
          end
         
          if config[:scripts]["pre-start"]
            Dployr::Provision::Hook.new @ip, config, "pre-provision"
          end
          if config[:scripts]["start"]
            Dployr::Provision::Hook.new @ip, config, "provision"
          end
          if config[:scripts]["post-start"]
            Dployr::Provision::Hook.new @ip, config, "post-provision"
          end
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end
