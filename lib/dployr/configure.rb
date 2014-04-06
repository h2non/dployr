require 'dployr/utils'

module Dployr
  class Configure

    include Dployr::Utils

    attr_reader :default, :instances

    def initialize
      @default = nil
      @config = nil
      @instances = []
      @merged = false
      yield self if block_given?
    end

    def set_default(config)
      @default = create_instance(nil, config) if config.is_a? Hash
    end

    def add_instance(name, config)
      @instances << create_instance(name, config)
      @instances.last
    end

    def get_instance(name)
      @instances.each { |i| return i if i.name == name }
    end

    def get_config_all(name, attributes = {})
      config = []
      @instances.each do |i| 
        config << get_config(i.name, attributes)
      end
      config
    end

    def get_config(name, attributes = {})
      instance = get_instance name
      ArgumentError.new "Instance do not exists" unless instance
      replace_variables merge_config instance
    end

    private

    def create_instance(name = 'unnamed', config)
      Dployr::Config::Instance.new do |i|
        i.name = name
        i.configure config
      end if config.is_a? Hash
    end

    def replace_variables(config)
      attrs = get_all_attributes config
      traverse_map config do |str|
        replace_env_vars(template str, attrs)
      end
      config
    end

    def get_all_attributes(config)
      attrs = {}
      config.each do |key, value|
        if key.to_sym == :attributes
          attrs.merge! value if value.is_a? Hash
        elsif value.is_a? Hash
          attrs.merge! get_all_attributes value
        end
      end if config.is_a? Hash
      attrs
    end

    def merge_config(instance)
      merge_providers merge_defaults instance.get_values
    end

    def merge_defaults(config)
      config = deep_merge @default.get_values, config if @default
      config
    end

    def merge_providers(config)
      key = get_real_key config, :providers
      if config[key].is_a? Hash
        config[key].each do |name, provider|
          provider = inherit_config provider, config
          regions = get_by_key provider, (get_real_key provider, :regions)
          if regions
            regions.each {|_, region| inherit_config region, provider }
          end
        end
      end
      config
    end

    def inherit_config(child, parent)
      keys = [ :attributes, :scripts, :authentication ]
      keys.each do |type|
        current = deep_copy(get_by_key parent, type)
        source = get_by_key child, type
        if type == :scripts
          current = [] unless current.is_a? Array
          current.concat source if source.is_a? Array
          current = current.compact.uniq
        else
          current = {} unless current.is_a? Hash
          current = deep_merge current, source
        end
        child[type] = current if current.length
      end
      child
    end
  end
end
