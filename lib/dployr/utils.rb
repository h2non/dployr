module Dployr
  module Utils

    module_function

    def merge(target, *origins)
      origins.each{|o| target = target.merge(o) }
      target
    end

    def template(str, data)
      raise ArgumentError.new 'Data must be a hash' unless data.is_a? Hash
      str.gsub(/%\{(\w+)\}/) do
        if data.has_key? $1
          data[$1]
        elsif data.has_key? $1.to_sym
          data[$1.to_sym]
        else
          ''
        end
      end
    end

    def replace_values(str, data)
      str % data if data.is_a? Hash or data.is_a? Array
    end

  end
end
