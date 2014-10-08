module Influxdb
  module Arel
    module Nodes
      class Merge < Binary
        def initialize(left, right)
          left = left.unalias if left.respond_to?(:unalias)
          right = right.unalias if right.respond_to?(:unalias)
          super(left, right)
        end
      end
    end
  end
end
