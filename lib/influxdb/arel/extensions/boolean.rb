module Influxdb
  module Arel
    module Extensions
      module Boolean
        def or(right)
          Nodes::Grouping.new(Nodes::Or.new(self, right))
        end

        def and(right)
          Nodes::And.new([self, right])
        end
      end
    end
  end
end
