require 'fog'
require 'dployr/compute/common'

module Dployr
  module Compute
    class GCE

      include Dployr::Compute::Common

      def initialize(options, attrs)
        @gce_options = {
          provider: 'Google',
          google_project: (attrs["google_project_id"] or ENV["GOOGLE_PROJECT_ID"]),
          google_client_email: (attrs["google_client_email"] or ENV["GOOGLE_CLIENT_EMAIL"]),
          google_key_location: (attrs["google_key_location"] or ENV["GOOGLE_KEY_LOCATION"]),
        }
        @compute = Fog::Compute.new @gce_options
        @attrs = attrs
        @options = options
      end

      def get_ip
        instance = get_instance(["PROVISIONING", "STAGING", "RUNNING"])
        if instance
          if @options[:public_ip]
            instance.public_ip_address
          else
            instance.private_ip_address
          end
        end
      end

      def get_info
        get_instance(["RUNNING", "STOPPED"])
      end

      def destroy
        instance = get_instance(["RUNNING", "STOPPED"])
        if instance
          puts "Destroying instance #{@attrs["name"]}...".yellow
          instance.destroy(async = false)
          puts "Destroying disk #{@attrs["name"]}...".yellow
          disk = @compute.disks.get(@attrs["name"])
          disk.destroy
          # Bug in fog. It return "persistent-disk-0" instead of boot disk name (usually the same name of the machine)
          # instance.disks.each do |disk|
          #   gdisk = @compute.disks.get(disk["deviceName"])
          #   gdisk.destroy
          # end
          return
        end
        raise "Instance #{@attrs["name"]} not found"
      end

      def halt
        instance = get_instance(["RUNNING"])
        if instance
          instance.disks.each do |disk|
            if disk["autoDelete"] == true
              raise "Cannot halt instance with autoDelete disks"
            end
          end
          instance.destroy
        else
          raise "Instance #{@attrs["name"]} not found"
        end
      end

      def start
        external_ip
        server = get_instance ["STOPPED"]
        if server
          puts "Starting stopped instance for #{@attrs["name"]} in #{@options[:region]}...".yellow
          server.start
        else
          puts "Creating boot disk...".yellow
          disks = create_disk
          if defined? @attrs["autodelete_disk"]
            autodelete_disk  = @attrs["autodelete_disk"]
          else
            autodelete_disk = false
          end

          puts "Creating new instance for #{@attrs["name"]} in #{@options[:region]}...".yellow

          start_options = {
            name: @attrs["name"],
            zone_name: @options[:region],
            machine_type: @attrs["instance_type"],
            network: @attrs["network"],
            disks: [disks.get_as_boot_disk(true, autodelete_disk)],
            external_ip: @attrs["public_ip"]
          }
          puts start_options.to_yaml
          server = @compute.servers.create(start_options)
        end

        print "Wait for instance to get online".yellow
        server.wait_for { print ".".yellow; ready? }
        print "\n"
        wait_ssh @attrs, server, @options[:public_ip]
      end

      def create_network(network_name, network_range, firewalls, routes)
        create_subnet(network_name, network_range)

        if firewalls.respond_to?("each")
          firewalls.each do |key, value|
            add_firewall(key , network_name, value["address"], value["protocol"], value["port"])
          end
        end
      end

      def delete_network(network_name, network_range, firewalls, routes)
        if exists("network", network_name)
          delete_routes(routes)

          if firewalls.respond_to?("each")
            firewalls.each do |key, value|
              delete_firewall(key)
            end
          end

          delete_subnet(network_name)
        else
          puts "\tNetwork #{network_name} not found. Nothing to delete!"
        end
      end

      private

      def external_ip
        if @attrs["public_ip"] == "new"
          puts "Looking for previous public_ip...".yellow
          ip = @compute.insert_address(@attrs["name"], @options[:region][0..-3])
          while true
            ip = @compute.get_address(@attrs["name"], @options[:region][0..-3])
            if ip[:body]["address"]
              @attrs["public_ip"].replace ip[:body]["address"]
              puts "Using public_ip #{@attrs["public_ip"]}".yellow
              break
            end
            puts "Waiting for ip to be ready...".yellow
            sleep 1
          end
        end
      end

      def create_disk
        disk = @compute.disks.get(@attrs["name"])
        if disk != nil
          puts "Disk #{@attrs["name"]} already created. Reusing it.".yellow
          return disk
        else
          puts "Creating new boot disk #{@attrs["name"]}...".yellow
          disk = @compute.disks.create(
            name: @attrs["name"],
            size_gb: 10,
            zone_name: @options[:region],
            source_image: @attrs["image_name"]
          )

          disk.wait_for { disk.ready? }
          disk
        end
      end

      # https://developers.google.com/compute/docs/instances
      def get_instance(states)
        servers = @compute.servers.all
        servers.each do |instance|
          if instance.name == @attrs["name"] and states.include? instance.state
            return instance
          end
        end
        nil
      end

      def create_subnet(network_name, private_net)
        if ! exists("network", network_name)
          @compute.insert_network(network_name, private_net)
          puts "\tNetwork #{network_name} created"
      else
        puts "\tNetwork #{network_name} already exists. Nothing to create!"
      end
      end

      def add_firewall(fw_name, network_name, source_range, ip_protocol, allowed_ports)
        allowed = [
            {
              IPProtocol: "#{ip_protocol}",
              ports: ["#{allowed_ports}"]
            }
        ]
        options = {}
        options[:source_ranges] = source_range

        @compute.insert_firewall(fw_name, allowed, network_name, options)
        puts "\tFirewall #{fw_name} created"
      end

      def exists(type, name)   
        if type == "network"
          list = @compute.list_networks.data[:body]
        elsif type == "route"
          list = @compute.list_routes.data[:body]
        else
          list = @compute.list_firewalls.data[:body]
          puts "name #{name}"
        end

        items = list["items"]
        if items.respond_to?("each")
          items.each do |item|
            if item["name"] == name
              return true
            end
          end
        end

        return false
      end

      def add_route(route_name, network_name, dest_range, priority, vm_name)
        # Get VM url --> https://www.googleapis.com/compute/..../vm_name
        server = @compute.get_server(vm_name,"europe-west1-a").data[:body]
        url_next_hop = server["selfLink"]

          network = @compute.get_network(network_name).data[:body]
        network_url = network["selfLink"]

        options = {}
        options[:description] = ""
        options[:next_hop_instance] = "#{url_next_hop}"
        # options[:next_hop_gateway] = ""
        # options[:next_hop_ip] = ""

        @compute.insert_route(route_name, network_url, dest_range, priority, options)
        puts "\tRoute #{route_name} created"
      end

      def delete_routes(routes)
        if routes.respond_to?("each")
          routes.each do |route|
            if gce_exist("route", route)
              @compute.delete_route(route) 
              puts "\tRoute #{route} deleted"
            else
              puts "\tRoute #{route} not found. Nothing to delete!"
          end
          end
        end
      end

      def delete_firewall(key)
        @compute.delete_firewall(key) 
        puts "\tFirewall #{key} deleted"
      end

      def delete_subnet(network_name)
        @compute.delete_network(network_name)
        puts "\tNetwork #{network_name} deleted"
      end

    end
  end
end
