require 'singleton'
require 'dployr/configuration'
require 'dployr/config/file_utils'

module Dployr

  def configure
    dployr = Init::instance
    yield dployr if block_given?
  end

  def config
    dployr = Init::instance
    dployr.config if dployr
  end

  module_function :configure, :config

  class Init

    attr_reader :file_path, :config

    def initialize
      @@instance = self
      @config = Dployr::Configuration.new
      load_file
    end

    @@instance = nil

    def self.instance
      @@instance
    end

    private

    def load_file
      @file_path = Dployr::Config::FileUtils.discover
      if @file_path.is_a? String
        if @file_path.include? '.yml' or @file_path.include? '.yaml'
          load_yaml @file_path
        else
          load @file_path
        end
      end
    end

    def load_yaml(file_path)
      config = Dployr::Config::FileUtils.read_yaml file_path
      if config.is_a? Hash
        config.each do |name, config|
          if key == 'default'
            @config.set_default value
          else
            @config.add_instance name, value
          end
        end
      end
    end
  end
end
