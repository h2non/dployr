require 'dployr/init'
require 'dployr/commands/utils'

module Dployr
  module Commands
    class Base

      include Dployr::Commands::Utils

      attr_reader :options, :name, :log, :attrs, :dployr

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attrs = parse_attributes @options[:attributes]
      end

      def create
        begin
          @dployr = Dployr::Init.new @attrs
          @dployr.load_config @options[:file]
        rescue Exception => e
          raise "Cannot load the config: #{e}"
        end
      end

    end
  end
end
