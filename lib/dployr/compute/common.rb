require 'net/ssh'

module Dployr
  module Compute
    module Common
      
      module_function

      def wait_ssh(attrs, server, use_public_ip)
        if use_public_ip
              @ip = server.public_ip_address
            else
              @ip = server.private_ip_address
            end
        print "Wait for ssh (#{@ip}) to get ready...".yellow
        while true
          begin
            Net::SSH.start(@ip, attrs["username"], :keys => attrs["private_key_path"]) do |ssh|
              print "\n"
              return @ip
            end
          rescue Exception => e
            print ".".yellow
            sleep 2
          end
        end
        print "\n"
      end
      

    end
  end
end
