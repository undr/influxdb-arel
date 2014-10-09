module Influxdb
  module Arel
    module Clauses
      class FromClause < Base
        def initialize(*tables, &block)
          @tables = tables
          super(&block)
        end

        def t(name)
          Nodes::Table.new(name)
        end

        def join(*tables)
          tables_union(Nodes::Join, tables, :merging)
        end

        def merge(*tables)
          tables_union(Nodes::Merge, tables, :merging)
        end

        def method_missing(method, *args, &block)
          t(method)
        end

        def to_arel
          super{|result| result ? (@tables | Array(result)) : @tables }.uniq
        end

        protected

        def tables_union(klass, tables, type)
          _tables = @tables + tables
          raise "IllegalSQLConstruct: The #{type} without first table" if _tables.size != 2
          first, last = arelize(_tables)
          klass.new(first, last)
        end

        def arelize_default_block
          ->(expr){ t(expr) }
        end
      end
    end
  end
end
