require 'fog'
require 'dployr/compute/common'
require 'ostruct'

module Dployr
  module Compute
    class BAREMETAL

      include Dployr::Compute::Common

      def initialize(options, attrs)
        @options = options
        @attrs = attrs
      end

      def get_ip
        if @options["public_ip"]
          @attrs["public_ip"]
        else
          @attrs["private_ip"]
        end
      end

      def get_info
        result = OpenStruct.new
        result.attributes = {
          public_ip: @attrs["public_ip"],
          private_ip: @attrs["private_ip"],
        }
        result
      end

      def destroy
        puts "Could not destroy baremetal machine".yellow
      end

      def halt
        puts "Could not halt baremetal machine".yellow
      end

      def start
        puts "Could not start baremetal machine".yellow
        wait_ssh attributes, server, @options["public_ip"]
      end

    end
  end
end
