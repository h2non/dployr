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

    def get_config_all(name, attributes = {})
      config = []
      @instances.each do |i| 
        config << get_config(i.name, attributes)
      end
      config
    end

    def get_config(name, attributes = {})
      config = {}
      instance = get_instance name
      ArgumentError.new "Instance do not exists" unless instance
      values = instance.get_values
      config.merge! merge_defaults values
      config = merge_providers config
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

    def merge_defaults(values)
      config = {}
      default = @default.get_values if @default
      values.each do |key, val|
        def_val = get_by_key default, key
        config[key] =
          if not defined? default
            val
          elsif def_val.is_a? Hash
            deep_merge(def_val, val)
          elsif def_val.is_a? Array
            def_val.concat(val).compact.uniq
          end
      end
      config
    end

    def merge_providers(values)
      providers = values[:providers]
      providers.each do |key, provider|
        provider.each do |tkey, tval|
          unless tkey == 'regions'
            sval = get_by_key values, tkey
            if sval
              if tval.is_a? Array
                tval.concat sval
              elsif tval.is_a? Hash
                provider[tkey] = deep_merge(tval, sval) if sval
              end
            end
          end
          # to do: merge regions
        end if providers[key].is_a? Hash
      end
      values
    end

  end
end
