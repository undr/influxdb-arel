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
          joining_tables = @tables + tables
          raise 'IllegalSQLConstruct: Joining without first table' if joining_tables.size != 2
          first, last = arelize(joining_tables)
          Nodes::Join.new(first, last)
        end

        def merge(*tables)
          merging_tables = @tables + tables
          raise 'IllegalSQLConstruct: Merging without first table' if merging_tables.size != 2
          first, last = arelize(merging_tables)
          Nodes::Merge.new(first, last)
        end

        def method_missing(method, *args, &block)
          t(method)
        end

        def to_arel
          super{|result| result ? (@tables | Array(result)) : @tables }.uniq
        end

        protected

        def arelize_default_block
          ->(expr){ t(expr) }
        end
      end
    end
  end
end
