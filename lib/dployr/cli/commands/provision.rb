require 'logger'
require 'dployr'
require 'dployr/utils'

module Dployr
  module CLI
    class Provision

      include Dployr::Utils

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attributes = parse_attributes @options[:attributes]

        begin
          # Read and parse config
          config = create.config.get_config @name
          # Pass instance to provision
          instance = Dployr::Provision::Provision.new config
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      def create
        begin
          @dployr = Dployr::Init.new(@attributes)
        rescue Exception => e
          raise "Cannot load the config: #{e}"
        end
      end

      def parse_attributes(attributes)
        if attributes.is_a? String
          if @options[:attributes][0] == '-'
            parse_flags attributes
          else
            parse_matrix attributes
          end
        end
      end

    end
  end
end
