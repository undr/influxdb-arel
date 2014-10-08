module Influxdb
  module Arel
    module Clauses
      module Expressions
        def count(expr)
          function_node(:Count, expr)
        end

        def sum(expr)
          function_node(:Sum, expr)
        end

        def max(expr)
          function_node(:Max, expr)
        end

        def min(expr)
          function_node(:Min, expr)
        end

        def mean(expr)
          function_node(:Mean, expr)
        end

        def mode(expr)
          function_node(:Mode, expr)
        end

        def median(expr)
          function_node(:Median, expr)
        end

        def distinct(expr)
          function_node(:Distinct, expr)
        end

        def percentile(expr, nth)
          function_node(:Percentile, expr, nth)
        end

        def histogram(expr, bucket_size = nil)
          function_node(:Histogram, expr, bucket_size || 1)
        end

        def derivative(expr)
          function_node(:Derivative, expr)
        end

        def stddev(expr)
          function_node(:Stddev, expr)
        end

        def first(expr)
          function_node(:First, expr)
        end

        def last(expr)
          function_node(:Last, expr)
        end

        def difference(expr)
          function_node(:Difference, expr)
        end

        def top(expr, size)
          function_node(:Top, expr, size)
        end

        def bottom(expr, size)
          function_node(:Bottom, expr, size)
        end
      end
    end
  end
end
