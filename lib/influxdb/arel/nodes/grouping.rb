module Influxdb
  module Arel
    module Nodes
      class Grouping < Unary
        include Predications
        include AliasPredication
        include Expressions
      end
    end
  end
end
