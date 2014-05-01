require 'net/ssh'

module Dployr
  module Scripts
    class Ssh

      def initialize(ip, instance)
        @ip = ip
        @username = instance[:attributes]["username"]
        @private_key_path = instance[:attributes]["private_key_path"]
        run
      end

      private

      def run
        puts "ssh -i #{@private_key_path} #{@username}@#{@ip}"
        system("ssh -i #{@private_key_path} #{@username}@#{@ip}")
      end

    end
  end
end
