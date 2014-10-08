module Influxdb
  module Arel
    module Nodes
      class Ordering < Unary
        alias :direction :expr

        REVERSALS = { asc: :desc, desc: :asc }.freeze

        def invert
          Ordering.new(REVERSALS[direction.to_sym])
        end
      end
    end
  end
end
