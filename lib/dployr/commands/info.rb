require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class Info < Base

      def initialize(options)
        super options
        begin
          create
          config = get_region_config options

          @name = config[:attributes]["name"]
          @provider = options[:provider].upcase
          @region = options[:region]

          @client = Dployr::Compute.const_get(@provider.to_sym).new @region

          @info = @client.get_info @name
          if @info
            puts @info.to_yaml
          else
            raise "#{@name} not found"
          end
          
        rescue Exception => e
          self.log.error e
          exit 1
        end
      end

    end
  end
end
