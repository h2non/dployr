require 'dployr/utils'

module Dployr
  class Configure

    include Dployr::Utils

    attr_reader :default, :instances

    def initialize
      @default = nil
      @instances = []
      yield self if block_given?
    end

    def set_default(config)
      @default = create_instance(nil, config)
    end

    def add_instance(name, config)
      @instances << create_instance(name, config)
      @instances.last
    end

    def get_config(name)
      config = {}
      instance = get_instance name

      setter = lambda do |k|
        key = k.to_s.gsub('@', '')
        if @default and has @default, key
          config[key] = deep_merge get_by_key(instance, key), get_by_key(@default, key)
        else
          config[key] = get_by_key(instance, key)
        end
      end

      instance.instance_variables.each { |k| setter.call k }
      if instance
        if @default
          config['attributes'] = deep_merge instance.attributes, @default.attributes
        else
          config['attributes'] = instance.attributes
        end
      end
      instance
    end

    def get_instance(name)
      @instances.each { |i| return i if i.name == name }
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
