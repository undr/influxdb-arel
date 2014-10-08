module Influxdb
  module Arel
    module Nodes
      class Attribute < Unary
        include Extensions::Expressions
        include Extensions::Predications
        include Extensions::AliasPredication
        include Extensions::Math
      end
    end
  end
end
