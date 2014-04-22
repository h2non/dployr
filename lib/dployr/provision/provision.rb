require 'logger'
require 'dployr'
require 'dployr/utils'

module Dployr
  module Provision
    class Provision

      include Dployr::Utils

      def initialize(instance)
        begin
          @log = Logger.new STDOUT 
          
          if instance[:scripts]["pre-provision"]
            Dployr::Provision::Hook.new instance, "pre-provision"
          end
          if instance[:scripts]["provision"]
            Dployr::Provision::Hook.new instance, "provision"
          end
          if instance[:scripts]["post-provision"]
            Dployr::Provision::Hook.new instance, "post-provision"
          end
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end