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
          Dployr::Provision::Shell.new instance
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end