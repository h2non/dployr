require 'fog'
require 'dployr/compute/common'

module Dployr
  module Compute
    class AWS
      
      include Dployr::Compute::Common
      
      def initialize(region)
        @options = {
          region: region[0..-2],
          provider: 'AWS',
          aws_access_key_id: ENV["AWS_ACCESS_KEY"],
          aws_secret_access_key: ENV["AWS_SECRET_KEY"]
        }
        @compute = Fog::Compute.new @options
      end

      def get_ip(name)
        instance = get_instance(name, ["running"])
        instance.private_ip_address if instance
      end

      def destroy(name)
        instance = get_instance(name, ["running", "stopped", "stopping"])
        if instance
          instance.destroy
        else
          raise "Instance #{name} not found"
        end
      end

      def halt(name)
        instance = get_instance(name, ["running"])
        if instance
          instance.stop
        else
          raise "Instance #{name} not found"
        end
      end

      def start(attributes, region)
        server = get_instance(attributes["name"], ["stopped", "stopping"])
        if server
          puts "Starting stopped instance for #{attributes["name"]} in #{region}...".yellow
          server.start
        else
          puts "Creating new instance for #{attributes["name"]} in #{region}...".yellow
          options = {
            availability_zone: region,
            flavor_id: attributes["instance_type"],
            image_id: attributes["ami"],
            key_name: attributes["keypair"],
            subnet_id: attributes["subnet_id"],
            security_group_ids: attributes["security_groups"],
            tags: { Name: attributes["name"] }
          }
          puts options.to_yaml
          server = @compute.servers.create(options)
        end
        print "Wait for instance to get online".yellow
        server.wait_for { print ".".yellow; ready? }
        print "\n"
        elastic_ip(attributes, server)
        wait_ssh(attributes, server)
      end
      
      private
      
      def get_instance(name, states)
        servers = @compute.servers.all
        servers.each do |instance|
          if instance.tags["Name"] == name and states.include? instance.state
            return instance
          end
        end
        nil
      end
      
      def elastic_ip(attributes, server)
        if attributes["public_ip"]
          if attributes["public_ip"] == "new"
            puts "Creating new elastic ip...".yellow
            response = @compute.allocate_address(server.vpc_id)
            allocation_id = response[:body]["allocationId"]
            attributes["public_ip"] = response[:body]["publicIp"]
          else
            puts "Looking for elastic ip #{attributes["public_ip"]}...".yellow
            eip = @compute.addresses.get(attributes["public_ip"])
            allocation_id = eip.allocation_id
          end
          puts "Associating elastic ip #{attributes["public_ip"]}...".yellow
          @compute.associate_address(server.id,nil,nil,allocation_id)
        end
      end

    end
  end
end
