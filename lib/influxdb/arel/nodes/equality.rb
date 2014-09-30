module Influxdb
  module Arel
    module Nodes
      class Equality < Binary
        def operator; :== end
        alias :operand1 :left
        alias :operand2 :right
      end
    end
  end
end
