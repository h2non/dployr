module Dployr
  module Commands
    module Utils

      module_function

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

      def parse_attributes(attributes)
        if attributes.is_a? String
          if attributes[0] == '-'
            parse_flags attributes
          else
            parse_matrix attributes
          end
        end
      end

    end
  end
end
