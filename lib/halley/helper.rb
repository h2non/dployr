module Halley
  module Helper

    def merge target, *origins
      origins.each{|o| target = target.merge(o) }
      target
    end

    module_function :merge

  end
end
