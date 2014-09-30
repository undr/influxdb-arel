module Influxdb
  module Arel
    module Nodes
      class SqlLiteral < String
        include Expressions
        include Predications
        include AliasPredication

        def name
          self
        end

        def unalias
          self
        end

        def eql?(other)
          Table.comparable_classes.include?(other.class) && name == other.name
        end
      end
    end
  end
end
