require 'dployr/utils'

module Dployr
  module Config
    class Instance

      include Dployr::Utils

      attr_reader :attributes, :providers, :authentication, :scripts, :parents
      attr_accessor :name

      def initialize
        @name = 'unnamed'
        @attributes = {}
        @authentication = {}
        @scripts = []
        @providers = {}
        @parents = []
        yield self if block_given?
      end

      def configure(config)
        if config.is_a? Hash
          set_attributes get_by_key config, :attributes if has config, :attributes
          set_providers get_by_key config, :providers if has config, :providers
          set_auth get_by_key config, :authentication if has config, :authentication
          set_scripts get_by_key config, :scripts if has config, :scripts
          set_parents get_by_key config, :extends if has config, :extends
        end
      end

      def get_values
        deep_copy({
          attributes: @attributes,
          authentication: @authentication,
          scripts: @scripts,
          providers: @providers,
          parents: @parents
        })
      end

      def set_attribute(key, value)
        @attributes[key] = value
      end

      def get_attribute(key)
        @attributes[key]
      end

      def remove_attribute(key)
        @attributes.remove key
      end

      def add_script(script)
        @scripts << script if script.is_a? Hash
      end

      def add_auth(key, value)
        @authentication[key] = value if key
      end

      def add_provider(name, provider)
        @providers[name] = provider if provider.is_a? Hash
      end

      def get_provider(index)
        @providers[index]
      end

      def remove_provider(provider)
        @providers.delete provider
      end

      private

      def set_auth(auth)
        @authentication = auth if auth.is_a? Hash
      end

      def set_providers(providers)
        @providers = providers if providers.is_a? Hash
      end

      def set_scripts(scripts)
        @scripts = scripts if scripts.is_a? Hash
      end

      def set_attributes(attrs)
        @attributes = attrs if attrs.is_a? Hash
      end

      def set_parents(parents)
        parents = [ parents ] if parents.is_a? String
        @parents.concat parents if parents.is_a? Array
      end

    end
  end
end
