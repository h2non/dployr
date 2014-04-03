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

      instance.instance_variables.each do |k|
        key = k.to_s.gsub('@', '')
        config[key] = val = instance.instance_variable_get k
        if @default
          def_val = @default.instance_variable_get k
          config[key] =
            if def_val.is_a? Hash
              deep_merge(def_val, val)
            elsif def_val.is_a? Array
              def_val.concat(val).compact.uniq
            end
        end
      end

      config
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
