module Influxdb
  module Arel
    module Nodes
      class Function < Node
        include AliasPredication
        include Math

        attr_accessor :expressions

        def initialize(expr)
          super()
          self.expressions = expr
        end

        def hash
          expressions.hash
        end

        def eql?(other)
          self.class == other.class && expressions == other.expressions
        end
      end

      %w{
        Count
        Sum
        Max
        Min
        Mean
        Mode
        Median
        Distinct
        Percentile
        Histogram
        Derivative
        Stddev
        First
        Last
        Difference
        Top
        Bottom
      }.each do |name|
        const_set(name, Class.new(Function))
      end
    end
  end
end
