require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Start
    class Start

      include Dployr::Utils

      def initialize(instance, options)
        begin
          @log = Logger.new STDOUT
          
          @name = instance[:attributes]["name"]
          @provider = options[:provider]
          @region = options[:region]
          @attributes = instance[:providers][@provider]["regions"][@region]["attributes"]
          
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
         
          if instance[:scripts]["pre-start"]
            Dployr::Provision::Hook.new @ip, instance, "pre-provision"
          end
          if instance[:scripts]["start"]
            Dployr::Provision::Hook.new @ip, instance, "provision"
          end
          if instance[:scripts]["post-start"]
            Dployr::Provision::Hook.new @ip, instance, "post-provision"
          end
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end
