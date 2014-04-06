require 'dployr/configuration'

module Dployr

  def init
    dployr = Init.new
    yield dployr if block_given?
  end

  module_function :init

  class Init

    def initialize
      @config = Dployr::Configuration.new
      @file_path = Dployr::Config::File.discover
      load_file
    end

    def load_file
      if @file_path

      end
    end

  end
end
