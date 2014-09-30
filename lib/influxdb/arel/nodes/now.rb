module Influxdb
  module Arel
    module Nodes
      class Now < Node
        include Math

        def eql?(other)
          self.class == other.class
        end

        alias :== :eql?
      end
    end
  end
end
