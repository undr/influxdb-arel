module Influxdb
  module Arel
    module Extensions
      module Math
        def *(other)
          Nodes::Multiplication.new(self, other)
        end

        def +(other)
          Nodes::Grouping.new(Nodes::Addition.new(self, other))
        end

        def -(other)
          Nodes::Grouping.new(Nodes::Subtraction.new(self, other))
        end

        def /(other)
          Nodes::Division.new(self, other)
        end
      end
    end
  end
end
