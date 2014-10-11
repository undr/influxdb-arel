module Influxdb
  module Arel
    module Nodes
      class Attribute < Unary
        include Extensions::Expressions
        include Extensions::Predications
        include Extensions::AliasPredication
        include Extensions::Math

        def time?
          value.to_s == 'time'
        end

        def sequence_number?
          value.to_s == 'sequence_number'
        end
      end
    end
  end
end
