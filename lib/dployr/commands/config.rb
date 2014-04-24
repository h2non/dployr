require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Commands
    class Config

      include Dployr::Utils

      def initialize(config, options)
        begin
          puts "Options:", options.to_yaml
          puts "\nConfig:", config.to_yaml
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
      
    end
  end
end
