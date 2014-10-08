module Influxdb
  module Arel
    module Nodes
      class Table < Unary
        include Extensions::JoiningMerging

        alias :name :value

        def as(name)
          TableAlias.new(self, name)
        end

        def unalias
          self
        end
      end
    end
  end
end
