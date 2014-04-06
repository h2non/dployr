module Dployr
  module Utils

    module_function

    MERGE_OPTIONS = { merge_hash_arrays: false, knockout_prefix: false }

    def has(hash, key)
      (hash.is_a? Hash and
        (hash.key? key or hash.key? key.to_sym or hash.key? key.to_s))
    end

    def get_by_key(hash, key)
      if hash.is_a? Hash
        hash[key] or hash[key.to_sym] or hash[key.to_s]
      end
    end

    def get_real_key(hash, key)
      if hash.is_a? Hash
        if hash.key? key
          key
        elsif hash.key? key.to_sym
          key.to_sym
        elsif hash.key? key.to_s
          key.to_s
        end
      end
    end

    def merge(target, *origins)
      origins.each { |h| target = target.merge h }
      target
    end

    def deep_merge(target = {}, *origins)
      origins.each do |h|
        target.deep_merge! h, MERGE_OPTIONS if h.is_a? Hash
      end
      target
    end

    def deep_copy(o)
      Marshal.load Marshal.dump o
    end

    def parse_matrix(str)
      hash = {}
      str.split(';').each do |val|
        val = val.split '='
        hash[val.first.strip] = val.last.strip
      end if str.is_a? String
      hash
    end

    def template(str, data)
      raise ArgumentError.new 'Data must be a hash' unless data.is_a? Hash
      str.gsub(/%\{(\w+)\}/) do
        if data.key? $1
          data[$1]
        elsif data.key? $1.to_sym
          data[$1.to_sym]
        else
          ''
        end
      end
    end

    def replace_env_vars(str)
      str.gsub(/\$\{(\w+)\}/) do
        if ENV.key? $1
          ENV[$1]
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
        hash.each {|k, v| hash[k] = traverse_map v, &block}
      end
      hash
    end

  end
end
