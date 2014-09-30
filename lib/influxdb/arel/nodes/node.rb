module Influxdb
  module Arel
    module Nodes
      class Node
        def or(right)
          Nodes::Grouping.new(Nodes::Or.new(self, right))
        end

        def and(right)
          Nodes::And.new([self, right])
        end

        def to_sql
          Visitor.new.accept(self)
        end
      end
    end
  end
end
