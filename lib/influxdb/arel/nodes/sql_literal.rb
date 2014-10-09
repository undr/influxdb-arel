module Influxdb
  module Arel
    module Nodes
      class SqlLiteral < String
        include Extensions::Expressions
        include Extensions::Predications
        include Extensions::AliasPredication
        include Extensions::BooleanPredications

        def name
          self
        end

        def eql?(other)
          self.class == other.class && name == other.name
        end
      end
    end
  end
end
