module Halley
  module Config
    class Instance

      attr_reader :attributes, :providers, :auth, :scripts

      def initialize
        @attributes = {}
        @auth = {}
        @scripts = []
        @providers = []
        yield self if block_given?
      end

      def set_values(params)
        if params.is_a?(Hash)
          set_attributes params.attributes if params.attributes
          set_providers params.providers if params.providers
          set_auth params.auth if params.auth
          set_scripts params.scripts if params.scripts
        end
      end

      def add_attribute(key, value)
        @attributes[key] = value
      end

      def set_attributes(attrs)
        @attributes = attrs
      end

      def get_attribute(key)
        @attributes[key]
      end

      def remove_attribute(key)
        @attributes.remove key
      end

      def set_auth(auth)
        @auth = auth if auth.is_a?(Hash)
      end

      def add_script(script)
        @scripts << script if script.is_a?(Array)
      end

      def set_scripts(scripts)
        @scripts = scripts if scripts.is_a?(Array)
      end

      def set_providers
        @providers = yield self if block_given?
      end

      def add_provider(provider)
        @providers << provider if provider.is_a?(Hash)
      end

      def get_provider(index)
        @providers.at index
      end

      def set_providers(providers)
        @providers = providers
      end

      def remove_provider(provider)
        @providers.delete provider
      end

    end
  end
end
