require 'fog'

module Dployr
  module Compute
    class Client

      attr_reader :client

      DEFAULT = {
        provider: 'AWS'
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
