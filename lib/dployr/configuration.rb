require 'dployr/utils'

module Dployr
  class Configuration

    include Dployr::Utils

    attr_reader :default, :instances

    def initialize(attributes = {})
      @default = nil
      @config = nil
      @instances = []
      @merged = false
      @attributes = attributes.is_a?(Hash) ? attributes : {}
      yield self if block_given?
    end

    def exists?
      (!@default.nil? or @instances.length >= 1)
    end

    def set_default(config)
      @default = create_instance 'default', config if config.is_a? Hash
    end

    def add_instance(name, config)
      @instances << create_instance(name, config) if config.is_a? Hash
      @instances.last
    end

    def get_instance(name)
      @instances.each { |i| return i if i.name.to_s == name.to_s }
      nil
    end

    def get_config(name, attributes = {})
      instance = get_instance name
      attributes = @attributes.merge (attributes or {})
      raise ArgumentError.new "Instance '#{name.to_s}' do not exists" if instance.nil?
      replace_variables merge_config(instance), replace_variables(attributes)
    end

    def get_config_all(attributes = {})
      config = []
      @instances.each do |i|
        config << get_config(i.name, attributes)
      end
      config
    end

    def get_provider(name, provider, attributes = {})
      config = get_config name, attributes
      if config.is_a? Hash
        config = config[get_real_key(config, :providers)]
        if config.is_a? Hash
          return config[get_real_key(config, provider)]
        end
      end
    end

    def get_region(name, provider, region, attributes = {})
      provider = get_provider name, provider, attributes
      if provider.is_a? Hash
        regions = get_by_key provider, :regions
        return get_by_key regions, region
      end
    end

    def each(type = :providers)
      config = get_config_all
      config.each { |i| yield i if block_given? }
    end

    private

    def create_instance(name = 'unnamed', config)
      Dployr::Config::Instance.new do |i|
        i.name = name
        i.configure config
      end if config.is_a? Hash
    end

    def replace_variables(config, attributes = {})
      if config.is_a? Hash
        attrs = get_all_attributes config
        attrs.merge! attributes if attributes.is_a? Hash
        traverse_map config do |str, key|
          replace_env_vars template(str, attrs)
        end
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
      merge_providers merge_parents merge_defaults instance.get_values
    end

    def merge_defaults(config)
      config = deep_merge @default.get_values, config if @default
      config
    end

    def merge_providers(config)
      key = get_real_key config, :providers
      if config[key].is_a? Hash
        config[key].each do |name, provider|
          provider = replace_keywords 'provider', name, inherit_config(provider, config)
          regions = get_by_key provider, get_real_key(provider, :regions)
          regions.each do |name, region|
            regions[name] = replace_keywords 'region', name, inherit_config(region, provider)
          end if regions
        end
      end
      config
    end

    def replace_keywords(keyword, value, hash)
      traverse_map hash do |str|
        str.gsub "${#{keyword.to_s}}", value.to_s
      end if hash.is_a? Hash
    end

    def inherit_config(child, parent)
      keys = [ :attributes, :scripts, :authentication ]
      keys.each do |type|
        current = deep_copy get_by_key(parent, type)
        source = get_by_key child, type
        if current and source
          raise Error.new "Cannot merge different types: #{parent}" if current.class != source.class
        end
        if type.to_sym == :scripts and current.is_a? Array
          current = [] unless current.is_a? Array
          current.concat source if source.is_a? Array
          current = current.compact.uniq
        else
          current = {} unless current.is_a? Hash
          current = deep_merge current, source
        end
        child.delete type.to_s unless child[type.to_s].nil?
        child[type.to_sym] = current if current
      end
      child
    end

    def merge_parents(child)
      parents = get_by_key child, :parents
      parents = [ parents ] if parents.is_a? String
      parents.each do |parent|
        parent = get_instance parent
        child = deep_merge parent.get_values, child unless parent.nil?
      end if parents.is_a? Array
      child
    end
  end
end
