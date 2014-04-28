require 'dployr/configuration'
require 'dployr/config/file_utils'

module Dployr

  module_function

  def configure(attributes = {})
    dployr = Init::instance
    yield dployr if block_given?
  end

  def config
    dployr = Init::instance
    dployr.config if dployr
  end

  def load(file_path)
    if Dployr::Config::FileUtils.yaml_file? file_path
      Dployr::Config::FileUtils.read_yaml file_path
    else
      load file_path
    end
  end

  class Init

    include Dployr::Config::FileUtils

    attr_reader :config
    attr_accessor :file_path

    @@instance = nil

    def initialize(attributes = {})
      @@instance = self
      @config = Dployr::Configuration.new attributes
      @file_path = nil
    end

    def self.instance
      @@instance
    end

    def load_config(file_path = nil)
      if file_path
        @file_path = file_path
      else
        @file_path = discover
      end
      set_config @file_path
    end

    private

    def set_config(file_path)
      if @file_path.is_a? String
        if yaml_file? @file_path
          load_yaml @file_path
        else
          load @file_path
        end
      end
    end

    def load_yaml(file_path)
      config = read_yaml file_path
      if config.is_a? Hash
        config.each do |name, config|
          if name == 'default'
            @config.set_default config
          else
            @config.add_instance name, config
          end
        end
      end
    end

  end
end
