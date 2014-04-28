require 'fog'
require 'net/ssh'

module Dployr
  module Compute
    class GCE

        def initialize(region)
          @options = {
            provider: 'Google',
            google_project: ENV["GOOGLE_PROJECT_ID"],
            google_client_email: ENV["GOOGLE_CLIENT_EMAIL"],
            google_key_location: ENV["GOOGLE_KEY_LOCATION"]
          }
          @compute = Fog::Compute.new @options
        end

        # https://developers.google.com/compute/docs/instances
        # private
        def get_instance(name, states)
          servers = @compute.servers.all
          servers.each do |instance|
            if instance.name == name and states.include? instance.state
              return instance
            end
          end
          return nil
        end

        def get_ip(name)
          instance = get_instance(name, ["PROVISIONING", "STAGING", "RUNNING"])
          if instance
            return instance.private_ip_address
          end
        end

        def destroy(name)
          instance = get_instance(name, ["RUNNING", "STOPPED"])
          if instance
            instance.destroy
            instance.disks.each do |disk|
              disk.destroy
            end
          end
          raise "Instance #{name} not found"
        end

        def halt(name)
          instance = get_instance(name, ["RUNNING"])
          if instance
            instance.disks.each do |disk|
              if disk["autoDelete"] == true
                raise "Cannot halt instance with autoDelete disks"
              end
            end
            return instance.destroy
          end
          raise "Instance #{name} not found"
        end
        
        def create_disk(name, size_gb, zone_name, image_name)
          disk = @compute.disks.get(name)
          if disk != nil
            puts "Disk #{name} already created. Reusing it.".yellow
            return disk
          else
            puts "Creating new boot disk #{name}...".yellow
            disk = @compute.disks.create(
              name: name,
              size_gb: size_gb,
              zone_name: zone_name,
              source_image: image_name
            )
          
            disk.wait_for { disk.ready? }
            return disk
          end
        end

        def start(attributes, region)
          server = get_instance(attributes["name"], ["stopped", "stopping"])
          if server
            puts "Starting stopped instance for #{attributes["name"]} in #{region}...".yellow
            server.start
          else
            disks = create_disk(attributes["name"], 10, region, attributes["image_name"])
            if defined? attributes["autodelete_disk"]
              autodelete_disk  = attributes["autodelete_disk"]
            else
              autodelete_disk = false
            end
            
            puts "Creating new instance for #{attributes["name"]} in #{region}...".yellow
            
            options = {
              name: attributes["name"],
              zone_name: region,
              machine_type: attributes["instance_type"],
              network: attributes["network"],
              disks: [disks.get_as_boot_disk(true, autodelete_disk)],
            }
            
            puts options.to_yaml
            server = @compute.servers.create(options)
          end
          print "Wait for instance to get online".yellow
          server.wait_for { print ".".yellow; ready? }

          print "\nWait for ssh to get ready...".yellow
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
          return nil
      end

    end
  end
end
