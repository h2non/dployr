require 'net/ssh'

module Dployr
  module Compute
    module Common
      
      module_function

      def wait_ssh(attributes, server)
        print "Wait for ssh to get ready...".yellow
        while true
          begin
            Net::SSH.start(server.private_ip_address, attributes["username"], :keys => attributes["private_key_path"]) do |ssh|
              print "\n"
              return server.private_ip_address
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
