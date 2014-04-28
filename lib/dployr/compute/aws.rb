require 'fog'
require 'net/ssh'

module Dployr
  module Compute
    class AWS

        def initialize(region)
          @options = {
            region: region[0..-2],
            provider: 'AWS',
            aws_access_key_id: ENV["AWS_ACCESS_KEY"],
            aws_secret_access_key: ENV["AWS_SECRET_KEY"]
          }
          @compute = Fog::Compute.new @options
        end

        # private
        def get_instance(name, states)
          servers = @compute.servers.all
          servers.each do |instance|
            if instance.tags["Name"] == name and states.include? instance.state
              return instance
            end
          end
          return nil
        end

        def get_ip(name)
          instance = get_instance(name, ["running"])
          if instance
            return instance.private_ip_address
          end
        end

        def destroy(name)
          instance = get_instance(name, ["running", "stopped", "stopping"])
          if instance
            return instance.destroy
          end
          raise "Instance #{name} not found"
        end

        def halt(name)
          instance = get_instance(name, ["running"])
          if instance
            return instance.stop
          end
          raise "Instance #{name} not found"
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
              #private_ip_address        : private_ip_address,
              #user_data                 : user_data,
              #elastic_ip                : elastic_ip,
              #allocate_elastic_ip       : allocate_elastic_ip,
              #block_device_mapping      : block_device_mapping,
              #instance_initiated_shutdown_behavior : terminate_on_shutdown == true ? "terminate" : nil,
              #monitoring                : monitoring,
              #ebs_optimized             : ebs_optimized
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
