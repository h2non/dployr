require 'logger'
require 'net/ssh'
require 'colorize'
require 'dployr/utils'

module Dployr
  module Scripts
    class Local_Shell

      include Dployr::Utils

      def initialize(script)
        @log = Logger.new STDOUT
        @script = script

        begin
          start
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      private

      def start
        command = @script["local_path"]
        arguments = @script["args"]

        puts "Running local script '#{command} #{arguments}'".yellow
        result = system(command + ' ' + arguments)
        if result == false
          raise "Exit code non zero when running local script '#{command} #{arguments}'".yellow
        else
          puts "Local script '#{command} #{arguments}' finished succesfully".yellow
        end
      end

    end
  end
end
