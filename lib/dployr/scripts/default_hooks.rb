module Dployr
  module Scripts
    class Default_Hooks

      def initialize(ip, config, stage, command)
        @config = config
        @ip = ip
        @stage = stage

        if @config[:scripts]["pre-#{@stage}"]
          Dployr::Scripts::Hook.new @ip, config, "pre-#{@stage}"
        end
        @ip = command.action()
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
