module Influxdb
  module Arel
    module Extensions
      module Expressions
        def count
          Nodes::Count.new([self])
        end

        def sum
          Nodes::Sum.new([self])
        end

        def max
          Nodes::Max.new([self])
        end

        def min
          Nodes::Min.new([self])
        end

        def mean
          Nodes::Mean.new([self])
        end

        def mode
          Nodes::Mode.new([self])
        end

        def median
          Nodes::Median.new([self])
        end

        def distinct
          Nodes::Distinct.new([self])
        end

        def percentile(nth)
          Nodes::Percentile.new([self, nth])
        end

        def histogram(bucket_size = nil)
          Nodes::Histogram.new([self, bucket_size || 1.0])
        end

        def derivative
          Nodes::Derivative.new([self])
        end

        def stddev
          Nodes::Stddev.new([self])
        end

        def first
          Nodes::First.new([self])
        end

        def last
          Nodes::Last.new([self])
        end

        def difference
          Nodes::Difference.new([self])
        end

        def top(size)
          Nodes::Top.new([self, size])
        end

        def bottom(size)
          Nodes::Bottom.new([self, size])
        end
      end
    end
  end
end
