require 'fog'
require 'json'

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
        
        def get_ip(name)
          servers = @compute.servers.all
          servers.each do |instance|
            if instance.tags["Name"] == name
              return instance.private_ip_address
            end
          end
          return nil
        end
        
        def start(attributes, region)
          puts attributes.to_json
          options = {
            :availability_zone         => region,
            :flavor_id                 => attributes["instance_type"],
            :image_id                  => attributes["ami"],
            :key_name                  => attributes["keypair"],
            #:private_ip_address        => private_ip_address,
            :subnet_id                 => attributes["subnet_id"],
            #:iam_instance_profile_arn  => iam_instance_profile_arn,
            #:iam_instance_profile_name => iam_instance_profile_name,
            :tags                      => {Name: attributes["name"]},
            #:user_data                 => user_data,
            #:elastic_ip                => elastic_ip,
            #:allocate_elastic_ip       => allocate_elastic_ip,
            #:block_device_mapping      => block_device_mapping,
            #:instance_initiated_shutdown_behavior => terminate_on_shutdown == true ? "terminate" : nil,
            #:monitoring                => monitoring,
            #:ebs_optimized             => ebs_optimized
          }
          puts options.inspect
          server = @compute.servers.create(options)
        end

    end
  end
end
