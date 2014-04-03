module Dployr
  class Configure

    attr_reader :default, :machines

    def initialize
      @default = nil
      @machines = []
      yield self if block_given?
    end

    def set_default(config)
      @default = create_instance(nil, config)
    end

    def add_instance(name, config)
      @machines << create_instance(name, config)
      @machines.last
    end

    def get_config(name)
      intance = get_instance name
      config = {}
      if instance
        if @default
          config['attributes'] = deep_merge instance.attributes, @default.attributes
        else
          config['attributes'] = instance.attributes
        end
      end
      puts instance.to_s
      instance
    end

    def get_instance(name)
      @machines.each { |i| return i if name == i.name }
    end

    private

    def create_instance(name = 'unnamed', config)
      Dployr::Config::Instance.new do |i|
        i.name = name
        i.configure config
      end if config.is_a? Hash
    end

  end
end
