module Dployr
  module Scripts
    class Default_Hooks
      
      def initialize(ip, config, stage, command)
        @config = config
        @ip = ip
        @stage = stage

        if @config[:scripts].is_a?(Hash) and @config[:scripts]["pre-#{@stage}"]
          Dployr::Scripts::Hook.new @ip, config, "pre-#{@stage}"
        end
        @ip = command.action()
        if @config[:scripts].is_a?(Hash) and @config[:scripts][@stage]
          Dployr::Scripts::Hook.new @ip, config, "#{@stage}"
        end
        if @config[:scripts].is_a?(Hash) and @config[:scripts]["post-#{@stage}"]
          Dployr::Scripts::Hook.new @ip, config, "post-#{@stage}"
        end 
      end      
      
    end
  end
end
