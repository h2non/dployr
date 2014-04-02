module Dployr
  class Configure

    def initialize(options)
      @defaults = {}
      @machines = []
    end

    def set_defaults(config)
      @defaults = create_instance config
    end

    def add_instance(config)
      @machines << create_instance(config)
    end

    private

    def create_instance(config)
      Dployr::Config::Instance.new do |i|
        i.configure config
      end if config.is_a? Hash
    end

  end
end
