require 'logger'
require 'dployr'
require 'dployr/utils'
require 'colorize'

module Dployr
  module Provision
    class Hook

      include Dployr::Utils

      def initialize(instance, stage)
        begin
          @log = Logger.new STDOUT

          host = instance[:attributes]["name"]
          username = instance[:attributes]["username"]
          private_key_path = instance[:attributes]["private_key_path"]
          
          puts "STAGE '#{stage}':".yellow
          instance[:scripts][stage].each do |script|
            if script["target"]
              Dployr::Provision::Scp.new host, username, private_key_path, script
            else
              Dployr::Provision::Shell.new host, username, private_key_path, script
            end   
            
          end         
          
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end