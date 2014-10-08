module Influxdb
  module Arel
    module Clauses
      class GroupClause < Base
        def initialize(*attributes, &block)
          @attributes = attributes
          super(&block)
        end

        def a(name)
          Nodes::Attribute.new(name)
        end

        def time(duration)
          Nodes::Time.new(Arel.arelize(duration))
        end

        def method_missing(method, *args, &block)
          a(method)
        end

        def to_arel
          super{|result| result ? (@attributes | Array(result)) : @attributes }
        end

        protected

        def arelize_default_block
          ->(expr){ a(expr) }
        end
      end
    end
  end
end
