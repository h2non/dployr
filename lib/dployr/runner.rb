module Dployr

  class Runner

    attr_accessor :config

    def initialize
      @server = Server.new
      yield @server if block_given?
    end

  end

  class Server

    attr_accessor :attributes

    DEFAULTS = {
      :flavor_id => 't1.micro',
      :image_id => nil,
      :key_name => nil
    }

    def initialize
      @provider = :aws
      @regions = []
      @server = {}
      @attributes = {}.merge DEFAULTS
      yield self if block_given?
    end

    def server
      yield @server if block_given?
    end

    def region
      yield @regions if block_given?
    end

    def set(attributes)
      @attributes.merge! attributes
    end

    def get(key = nil)
      if key
        @attributes.key key
      else
        @attributes
      end
    end

  end
end
