require 'fog'

module Halley
  module Compute
    class Client

      attr_reader :client

      DEFAULT = {
        :flavor_id => 1
      }

      def initialize(options)
        @options = options
        @client = Fog::Compute.new DEFAULT.merge options
      end

      def servers
        @client.servers
      end

      def create_server(options)
        @client.servers.create options
      end

    end
  end
end
