module Influxdb
  module Arel
    module Clauses
      class Base
        def initialize(&block)
          @block = block
          @outer = eval('self', block.binding) if block
        end

        def o(&block)
          @outer.instance_exec(&block)
        end

        def to_arel
          result = nil
          result = instance_eval(&@block) if @block
          result = yield result if block_given?
          arelize(result)
        end

        protected

        def arelize_default_block
          ->(expr){ Arel.sql(expr) }
        end

        def arelize(expr, &block)
          block ||= arelize_default_block
          Arel.arelize(expr, &block)
        end
      end
    end
  end
end
