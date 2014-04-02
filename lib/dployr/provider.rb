require 'fog'

module Dployr
  class Provider

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

  end
end
