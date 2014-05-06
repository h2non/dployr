require 'dployr/commands/base'
require 'dployr/compute/aws'

module Dployr
  module Commands
    class Info < Base

      def initialize(options)
        super options
        begin
          @client = Dployr::Compute.const_get(@provider.to_sym).new(@options, @p_attrs)
          @info = @client.get_info
          if @info
            puts @info.attributes.to_yaml
          else
            raise "#{@p_attrs["name"]} not found"
          end
        rescue Exception => e
          self.log.error e
          exit 1
        end
      end

    end
  end
end
