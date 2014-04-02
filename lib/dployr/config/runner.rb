module Dployr
  class Config

    def initialize(options)
      @defaults = nil
      @machines = []
    end

    def set_defaults(config)
      @defaults = config if config.is_a? Hash
    end

    def add_instance(config)
      @machines << Dployr::Config::Instance.new do |i|
        i.configure config
      end
    end

  end
end
