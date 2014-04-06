module Dployr
  module Logger

    module_function

    def log(*msg)
      msg.each { |msg| puts msg }
    end

  end
end
