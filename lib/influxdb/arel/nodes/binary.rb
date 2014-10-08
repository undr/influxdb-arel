module Influxdb
  module Arel
    module Nodes
      class Binary < Node
        attr_accessor :left, :right

        def initialize(left, right)
          super()
          left = left.to_s if Symbol === left
          right = right.to_s if Symbol === right
          self.left = left
          self.right = right
        end

        def initialize_copy(other)
          super
          self.left = left.clone if left
          self.right = right.clone if right
        end

        def hash
          [left, right].hash
        end

        def eql?(other)
          self.class == other.class && left == other.left && right == other.right
        end

        alias :== :eql?
      end

      %w{
        As
        DoesNotMatch
        GreaterThan
        GreaterThanOrEqual
        Join
        LessThan
        LessThanOrEqual
        Matches
        NotEqual
        Or
      }.each do |name|
        const_set(name, Class.new(Binary))
      end
    end
  end
end
