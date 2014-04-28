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
