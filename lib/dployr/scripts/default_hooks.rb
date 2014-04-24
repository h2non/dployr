require 'logger'
require 'dployr/utils'
require 'colorize'

module Dployr
  module Scripts
    class Default_Hooks

      include Dployr::Utils

      def initialize(ip, config, stage)
        @log = Logger.new STDOUT
        @config = config
        @ip = ip
        @stage = stage
      
        if @config[:scripts]["pre-#{@stage}"]
          Dployr::Scripts::Hook.new @ip, config, "pre-#{@stage}"
        end
        if @config[:scripts][@stage]
          Dployr::Scripts::Hook.new @ip, config, "#{@stage}"
        end
        if @config[:scripts]["post-#{@stage}"]
          Dployr::Scripts::Hook.new @ip, config, "#{@stage}"
        end
      end
      
    end
  end
end
