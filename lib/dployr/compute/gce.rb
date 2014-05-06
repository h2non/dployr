require 'fog'
require 'dployr/compute/common'

module Dployr
  module Compute
    class GCE

      include Dployr::Compute::Common
      
      def initialize(options, attrs)
        @gce_options = {
          provider: 'Google',
          google_project: ENV["GOOGLE_PROJECT_ID"],
          google_client_email: ENV["GOOGLE_CLIENT_EMAIL"],
          google_key_location: ENV["GOOGLE_KEY_LOCATION"],
        }
        @compute = Fog::Compute.new @gce_options
        @attrs = attrs
        @options = options
      end

      def get_ip()
        instance = get_instance(["PROVISIONING", "STAGING", "RUNNING"])
        if instance
          if @options[:public_ip]
            return instance.public_ip_address
          else
            return instance.private_ip_address
          end
        end
      end
      
      def get_info()
        get_instance(["RUNNING", "STOPPED"])
      end

      def destroy()
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

      def halt()
        instance = get_instance(["RUNNING"])
        if instance
          instance.disks.each do |disk|
            if disk["autoDelete"] == true
              raise "Cannot halt instance with autoDelete disks"
            end
          end
          return instance.destroy
        end
        raise "Instance #{@attrs["name"]} not found"
      end

      def start()
        external_ip()
        server = get_instance(["STOPPED"])
        if server
          puts "Starting stopped instance for #{@attrs["name"]} in #{@options[:region]}...".yellow
          server.start
        else
          puts "Creating boot disk...".yellow
          disks = create_disk()
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
        wait_ssh(@attrs, server, @options[:public_ip])
    end
    
      private
      
      def external_ip()
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
      
      def create_disk()
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
          return disk
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
        return nil
      end

    end
  end
end
