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

        puts "Running local script '#{command} #{arguments}'".yellow
        total_command = command
          if arguments
            total_command =  command + ' ' + arguments
          end
        result = system(total_command)
        if result == false
          raise "Exit code non zero when running local script '#{total_command}'".yellow
        else
          puts "Local script '#{command} #{arguments}' finished succesfully".yellow
        end
      end

    end
  end
end
