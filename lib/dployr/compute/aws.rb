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
          aws_access_key_id: (attrs["aws_access_key"] or ENV["AWS_ACCESS_KEY"]),
          aws_secret_access_key: (attrs["aws_secret_key"] or ENV["AWS_SECRET_KEY"]),
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
        get_instance ["running", "stopped", "stopping"]
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

      def create_network(network_name, network_range, firewalls, routes)
        # Routes not used in AWS
        create_vpc(network_range)                # VPC + INTERNET GATEWAY
        create_subnet(network_range)             # SUBNET + ROUTE TABLE
        configure_security_group(firewalls)      # SECURITY GROUP
      end

      def delete_network(network_name, network_range, firewalls, routes)
        # Network_name, firewalls and routes not used. We only need "vpc_id"
        if exist_vpc(network_range)
          vpcId = get_vpcId(network_range)

          delete_route_tables(vpcId)
          delete_subnets(vpcId)
          delete_network_acls(vpcId)
          delete_internet_gateways(vpcId)
          delete_security_groups(vpcId)
          delete_vpc(vpcId)
        else
          puts "\tNetwork #{network_range} not found. Nothing to delete!"
        end
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

      def create_vpc(network_range)
        if ! exist_vpc(network_range)
          # Internet Gateway
          ig = @compute.create_internet_gateway
          igId = ig.body["internetGatewaySet"][0]["internetGatewayId"]
          puts "\tInternet Gateway #{igId} created!"

          @attrs["internetGatewayId"] = igId

          # VPC
          vpc = @compute.create_vpc(network_range)
          vpcId = vpc.body["vpcSet"][0]["vpcId"]
          puts "\tVPC #{vpcId} (#{network_range}) created!"

          # Associate both
          @compute.attach_internet_gateway(igId, vpcId)
          puts "\t\tBoth associated!"
        else
          puts "\tVPC #{network_range} already exists"
          vpcId = get_vpcId(network_range)
        end

        @attrs["vpcId"] = vpcId
      end

      def create_subnet(network_range)
        if ! exist_subnet(network_range)
          vpcId = @attrs["vpcId"]

          # SUBNET
          sn = @compute.create_subnet(vpcId, network_range)
          snId = sn.body["subnet"]["subnetId"]
          puts "\tSubnet #{snId} created!"

          @attrs["subnetId"] = snId

          # ROUTE TABLE
          rt = @compute.create_route_table(vpcId)
          rtId = rt.body["routeTable"][0]["routeTableId"]
          puts "\tRoute table #{rtId} created!"

          @attrs["routeTableId"] = rtId

          # Add route for internet gateway
          igId = @attrs["internetGatewayId"]
          @compute.create_route(rtId, "0.0.0.0/0", igId, instance_id = nil, network_interface_id = nil)

          # Associate both
          @compute.associate_route_table(rtId, snId)
          puts "\t\tBoth associated!"
        else
          puts "\tSubnet #{network_range} already exists"
        end
      end

      def configure_security_group(firewalls)

        timestamp = Time.now.to_i
        @attrs["securityGroupName"] = "SG-#{timestamp}"
        puts "\tConfiguring Security Group: #{@attrs["securityGroupName"]}"

        vpcId = @attrs["vpcId"]

        # Create Security Group
        sg = @compute.create_security_group( @attrs["securityGroupName"], "dployr", vpcId)
        @attrs["securityGroupId"] = sg.body["groupId"]
        puts "\t\tSecurity Group #{@attrs["securityGroupId"]} created!"

        # Create rules
        if firewalls.respond_to?("each")
          firewalls.each do |key, value|
            add_firewall( @attrs["securityGroupId"] , key, value["address"][0], value["protocol"], value["port"])
          end
        end

        puts "\tSecurity Group #{@attrs["securityGroupId"]} configured!"
      end

      def add_firewall(sgId, name, cidrIp, protocol, ports)
        # Split ports into "from" and "to"
        words = ports.split("-")
        if words.length > 1
          from = words[0].to_i
          to = words[1].to_i
        else
          from = to = words[0].to_i
        end

        group_name = "SG-plumbing"
        options = {}
        options["GroupId"] = "#{sgId}"
        options["CidrIp"] = "#{cidrIp}"
        options["FromPort"] = from
        options["IpProtocol"] = "#{protocol}"
        options["ToPort"] = to

        # Add rule
        asg = @compute.authorize_security_group_ingress(group_name, options)
        puts "\t\tRule #{name} added!"
      end

      def exist_vpc(name)
        list = @compute.describe_vpcs.data[:body]
        items = list["vpcSet"]
        if items.respond_to?("each")
          items.each do |item|
            if item["cidrBlock"] == name
              return true
            end
          end
        end
        return false
      end

      def exist_subnet(name)
        list = @compute.describe_subnets.data[:body]
        items = list["subnetSet"]
        if items.respond_to?("each")
          items.each do |item|
            if item["cidrBlock"] == name
              return true
            end
          end
        end
        return false
      end

      def get_vpcId(private_net)
        list = @compute.describe_vpcs.data[:body]
        items = list["vpcSet"]
        if items.respond_to?("each")
          items.each do |item|
            if item["cidrBlock"] == private_net
              return item["vpcId"]
            end
          end
        end
        return ""
      end

      # Route Tables
      # Delete non-default route tables from VPC. Default tables NOT allowed
      def delete_route_tables(vpcId)
        rts = @compute.describe_route_tables('vpc-id' => "#{vpcId}").body["routeTableSet"]
        if rts.respond_to?("each")
          rts.each do |rt|
            if ! rt["associationSet"][0]["main"] # non-default
              @compute.disassociate_route_table( rt["associationSet"][0]["routeTableAssociationId"] )
              @compute.delete_route_table( rt["routeTableId"] )
              puts "\tRoute table #{rt["routeTableId"]} deleted!"
            end
          end
        end
      end

      # Subnets
      # Delete subnets from VPC.
      def delete_subnets(vpcId)
        subnets = @compute.describe_subnets('vpc-id' => "#{vpcId}").body["subnetSet"]
        if subnets.respond_to?("each")
          subnets.each do |sn|
            @compute.delete_subnet( sn["subnetId"] )
            puts "\tSubnet #{sn["subnetId"]} deleted!"
          end
        end
      end

      # Network ACLs
      # Delete non-default network ACLs from VPC. Defaul ACLs NOT allowed
      def delete_network_acls(vpcId)
        acls = @compute.describe_network_acls('vpc-id' => "#{vpcId}").body["networkAclSet"]
        if acls.respond_to?("each")
          acls.each do |acl|
            if ! acl["default"] # non-default
              @compute.delete_network_acl( acl["networkAclId"] )
              puts "\tNetwork ACL #{acl["networkAclId"]} deleted!"
            end
          end
        end
      end

      # Internet Gateway
      # Delete internet gateways from VPC.
      def delete_internet_gateways(vpcId)
        igws = @compute.describe_internet_gateways('attachment.vpc-id' => "#{vpcId}").body["internetGatewaySet"]
        if igws.respond_to?("each")
          igws.each do |igw|
            @compute.detach_internet_gateway( igw["internetGatewayId"], vpcId )
            @compute.delete_internet_gateway( igw["internetGatewayId"] )
            puts "\tInternet gateway #{igw["internetGatewayId"]} deleted!"
          end
        end
      end

      # Security Group
      # Delete non-default security group from VPC. Default SG NOT allowed
      def delete_security_groups(vpcId)
        sgs = @compute.describe_security_groups('vpc-id' => "#{vpcId}").body["securityGroupInfo"]
        if sgs.respond_to?("each")
          sgs.each do |sg|
            if sg["groupName"] != "default" # non-default
              @compute.delete_security_group( nil, sg["groupId"] )
              puts "\tSecurity Group #{sg["groupId"]} deleted!"
            end
          end
        end
      end

      def delete_vpc(vpcId)
        if @compute.delete_vpc(vpcId)
          puts "\tVPC #{vpcId} deleted!"
        else
          puts "\tError deleting VPC #{vpcId}!"
        end
      end

    end
  end
end
