module Influxdb
  module Arel
    module Clauses
      class SelectClause < Base
        include Expressions

        def initialize(*attributes, &block)
          @attributes = attributes
          super(&block)
        end

        def a(name)
          Nodes::Attribute.new(name)
        end

        def method_missing(method, *args, &block)
          a(method)
        end

        def to_arel
          super{|result| result ? (@attributes | Array(result)) : @attributes }
        end

        protected

        def function_node(name, *args)
          args[0] = arelize(args[0])
          Nodes.const_get(name, *args)
        end

        def arelize_default_block
          ->(expr){ a(expr) }
        end
      end
    end
  end
end
