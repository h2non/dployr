module Halley
  module Helper

    module_function

    def merge(target, *origins)
      origins.each{|o| target = target.merge(o) }
      target
    end

  end
end
