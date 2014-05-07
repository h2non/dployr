require 'net/ssh'

module Dployr
  module Scripts
    class Local_Shell

      def initialize(script)
        @script = script
        start
      end

      private

      def start
        command = @script["local_path"]
        arguments = @script["args"]
        arguments = arguments.join ' ' if arguments.is_a? Array

        puts "Running local script '#{command} #{arguments}'".yellow
        total_command = command
        total_command =  command + ' ' + arguments if arguments

        result = system total_command
        if result == false
          raise "Exit code non zero when running local script '#{total_command}'"
        else
          puts "Local script '#{command} #{arguments}' finished succesfully".yellow
        end
      end

    end
  end
end
