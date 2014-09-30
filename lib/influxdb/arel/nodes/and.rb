module Influxdb
  module Arel
    module Nodes
      class And < Node
        attr_reader :children

        def initialize(children)
          super()
          @children = children
        end

        def left
          children.first
        end

        def right
          children[1]
        end

        def hash
          children.hash
        end

        def eql?(other)
          self.class == other.class && children == other.children
        end

        alias :== :eql?
      end
    end
  end
end
