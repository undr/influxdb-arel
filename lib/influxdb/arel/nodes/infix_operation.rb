module Influxdb
  module Arel
    module Nodes
      class InfixOperation < Binary
        include Expressions
        include Predications
        include AliasPredication
        include Math

        attr_reader :operator

        def initialize(operator, left, right)
          super(left, right)
          @operator = operator
        end
      end

      class Multiplication < InfixOperation
        def initialize(left, right)
          super(:*, left, right)
        end

        def as(name)
          Grouping.new(self).as(name)
        end
      end

      class Division < InfixOperation
        def initialize(left, right)
          super(:/, left, right)
        end

        def as(name)
          Grouping.new(self).as(name)
        end
      end

      class Addition < InfixOperation
        def initialize(left, right)
          super(:+, left, right)
        end
      end

      class Subtraction < InfixOperation
        def initialize(left, right)
          super(:-, left, right)
        end
      end
    end
  end
end
