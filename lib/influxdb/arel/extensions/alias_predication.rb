module Influxdb
  module Arel
    module Extensions
      module AliasPredication
        def as(other)
          Nodes::As.new(self, Arel.sql(other.to_s))
        end
      end
    end
  end
end
