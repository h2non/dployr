require 'deep_merge'

module Dployr
  module Utils

    MERGE_OPTIONS = { merge_hash_arrays: false, knockout_prefix: false }

    module_function

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

    def parse_flags(str)
      hash = {}
      str.gsub(/\s+/, ' ').strip.split(' ').each_slice(2) do |val|
        key = val.first
        if val.first.is_a? String
          key = key.gsub(/^\-+/, '').strip
          hash[key] = (val.last or '').strip
        end
      end if str.is_a? String
      hash
    end

    def replace_vars(str)
      str.gsub(/\%\{(\w+)\}/) { yield $1 }
    end

    def template(str, data)
      raise ArgumentError.new 'Data must be a hash' unless data.is_a? Hash
      replace_vars str do |match|
        key = get_real_key data, match
        if key
          data[key]
        else
          raise ArgumentError.new "Missing template variable: #{match}"
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

    def replace_placeholders(str, data)
      str % data if data.is_a? Hash or data.is_a? Array
    end

    def traverse_map(hash, &block)
      traverse_mapper hash, nil, &block
    end

    def traverse_mapper(hash, key, &block)
      case hash
      when String
        hash = yield hash, key
      when Array
        hash.map! { |item| traverse_mapper item, nil, &block }
      when Hash
        buf = {}
        hash.each do |k, v|
          if k.is_a? String
            new_key = yield k, k
            if new_key != k
              hash.delete k
              buf[new_key] = traverse_mapper v, new_key, &block
              next
            end
          end
          hash[k] = traverse_mapper v, k, &block
        end
        hash.merge! buf
      end
      hash
    end

  end
end
