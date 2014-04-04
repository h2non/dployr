module Dployr
  module Utils

    module_function

    MERGE_OPTIONS = { :merge_hash_arrays => true, :knockout_prefix => true }

    def has(hash, key)
      if hash.is_a? Hash
        if hash.has_key? key or hash.has_key? key.to_sym
          return true
        end
      end
      false
    end

    def get_by_key(hash, key)
      if hash.is_a? Hash
        hash[key] or hash[key.to_sym] or hash[key.to_s]
      end
    end

    def merge(target, *origins)
      origins.each { |h| target = target.merge h }
      target
    end

    def deep_merge(target, *origins)
      origins.each { |h| target.deep_merge! h, MERGE_OPTIONS }
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

    def traverse_map(hash, &block)
      case hash
      when String
        hash = yield hash
      when Array
        hash.map! {|item| traverse_map item, &block}
      when Hash
        hash.each {|k, v| hash[k] = traverse_map v, &block }
      end
      hash
    end

  end
end
