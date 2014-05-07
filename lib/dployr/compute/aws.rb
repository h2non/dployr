require 'fog'
require 'dployr/compute/common'

module Dployr
  module Compute
    class AWS

      include Dployr::Compute::Common

      def initialize(options, attrs)
        @aws_options = {
          region: options[:region][0..-2],
          provider: 'AWS',
          aws_access_key_id: ENV["AWS_ACCESS_KEY"],
          aws_secret_access_key: ENV["AWS_SECRET_KEY"],
        }
        @compute = Fog::Compute.new @aws_options
        @attrs = attrs
        @options = options
      end

      def get_ip
        instance = get_instance ["running"] # TODO: add starting states
        if instance
          if @options[:public_ip]
            instance.public_ip_address
          else
            instance.private_ip_address
          end
        end
      end

      def get_info
        get_instance(["running", "stopped", "stopping"])
      end

      def destroy
        instance = get_instance ["running", "stopped", "stopping"]
        if instance
          instance.destroy
        else
          raise "Instance #{@attrs["name"]} not found"
        end
      end

      def halt
        instance = get_instance ["running"]
        if instance
          instance.stop
        else
          raise "Instance #{@attrs["name"]} not found"
        end
      end

      def start
        server = get_instance ["stopped", "stopping"]
        if server
          puts "Starting stopped instance for #{@attrs["name"]} in #{@options[:region]}...".yellow
          server.start
        else
          puts "Creating new instance for #{@attrs["name"]} in #{@options[:region]}...".yellow
          options = {
            availability_zone: @options[:region],
            flavor_id: @attrs["instance_type"],
            image_id: @attrs["ami"],
            key_name: @attrs["keypair"],
            subnet_id: @attrs["subnet_id"],
            security_group_ids: @attrs["security_groups"],
            tags: { Name: @attrs["name"] }
          }
          puts options.to_yaml
          server = @compute.servers.create options
        end
        print "Wait for instance to get online".yellow
        server.wait_for { print ".".yellow; ready? }
        print "\n"
        elastic_ip server
        wait_ssh @attrs, server, @options[:public_ip]
      end

      private

      def get_instance(states)
        servers = @compute.servers.all
        servers.each do |instance|
          if instance.tags["Name"] == @attrs["name"] and states.include? instance.state
            return instance
          end
        end
        nil
      end

      def elastic_ip(server)
        if @attrs["public_ip"]
          if @attrs["public_ip"] == "new"
            puts "Creating new elastic ip...".yellow
            response = @compute.allocate_address server.vpc_id
            allocation_id = response[:body]["allocationId"]
            @attrs["public_ip"] = response[:body]["publicIp"]
          else
            puts "Looking for elastic ip #{@attrs["public_ip"]}...".yellow
            eip = @compute.addresses.get @attrs["public_ip"]
            allocation_id = eip.allocation_id
          end
          puts "Associating elastic ip #{@attrs["public_ip"]}...".yellow
          @compute.associate_address server.id, nil, nil, allocation_id
        end
      end

    end
  end
end
