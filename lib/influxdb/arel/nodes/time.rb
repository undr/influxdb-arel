module Influxdb
  module Arel
    module Nodes
      class Time < Unary
        def initialize(expr)
          expr = SqlLiteral.new(expr) if String === expr
          expr = SqlLiteral.new(expr.to_s) if Symbol === expr
          super(expr)
        end
      end
    end
  end
end
