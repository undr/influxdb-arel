module Influxdb
  module Arel
    class SelectManager < Arel::TreeManager
      DIRECTIONS = [:asc, :desc].freeze

      def initialize(*tables, &block)
        super()
        @ast = Nodes::SelectStatement.new
        from(*tables, &block)
      end

      def group(*attributes, &block)
        ast.groups |= Clauses::GroupClause.new(*attributes, &block).to_arel
        self
      end

      def group!(*attributes, &block)
        ast.groups = process_value_with_bang(Clauses::GroupClause, attributes, &block)
        self
      end

      def group_values
        ast.groups
      end

      def select(*attributes, &block)
        ast.attributes |= Clauses::SelectClause.new(*attributes, &block).to_arel
        self
      end

      def select!(*attributes, &block)
        ast.attributes = process_value_with_bang(Clauses::SelectClause, attributes, &block)
        self
      end

      def select_values
        ast.attributes
      end

      def fill(value)
        ast.fill = Nodes::Fill.new(value)
        self
      end

      def fill_value
        ast.fill
      end

      def from(*new_tables, &block)
        new_tables = new_tables.compact
        return self if new_tables.empty? && !block_given?

        expr = Clauses::FromClause.new(*new_tables, &block).to_arel

        case expr
        when Array
          regexps, merges, joins, others = separate_tables(expr.to_a)
          ast.regexp = Nodes::Table.new(regexps.first) if regexps
          ast.join = joins.first if joins
          ast.merge = merges.first if merges
          ast.tables = others
        when Nodes::Join
          ast.join = expr
        when Nodes::Merge
          ast.merge = expr
        when Regexp
          ast.regexp = expr
        else
          ast.tables = Array(expr)
        end

        self
      end

      def tables
        [ast.regexp] || ast.tables
      end

      def join(*joining_tables)
        ast.join = process_value_for_tables_union(Nodes::Join, joining_tables, :joining)
        self
      end

      def merge(*merging_tables)
        ast.merge = process_value_for_tables_union(Nodes::Merge, merging_tables, :merging)
        self
      end

      def order(expr)
        case
        when Nodes::Ordering === expr
          ast.order = expr
        when DIRECTIONS.include?(expr.to_sym)
          send(expr)
        end
        self
      end

      def desc
        ast.order = Nodes::Ordering.new('desc')
        self
      end

      def asc
        ast.order = Nodes::Ordering.new('asc')
        self
      end

      def invert_order
        ast.order = (ast.order && ast.order.invert) || Nodes::Ordering.new('asc')
        self
      end

      def order_value
        ast.order
      end

      def limit(limit)
        ast.limit = limit ? Nodes::Limit.new(limit) : nil
        self
      end

      def limit_value
        ast.limit
      end

      def into(table)
        ast.into = Nodes::Into.new(Arel.arelize(table))
        self
      end

      def into_value
        ast.into
      end

      def delete
        raise 'IllegalSQLConstruct: Ambiguous deletion operation' if ast.tables.size != 1
        DeleteManager.new.tap do |manager|
          manager.tables = ast.tables
          manager.regexp = ast.regexp
          manager.where_values = where_values
        end
      end

      private

      def process_value_with_bang(klass, attributes, &block)
        return nil if attributes.empty? && !block_given?
        klass.new(*attributes, &block).to_arel
      end

      def process_value_for_tables_union(klass, tables, type)
        _tables = (ast.tables + tables).compact
        raise "IllegalSQLConstruct: Ambiguous #{type} clause" if _tables.size != 2
        _tables = Arel.arelize(_tables){|expr| Nodes::Table.new(expr) }
        klass.new(*_tables)
      end

      def separate_tables(expr)
        grouped_tables = expr.group_by do |value|
          case value
          when Nodes::Join
            :joins
          when Nodes::Merge
            :merges
          when Regexp
            :regexp
          else
            :others
          end
        end
        grouped_tables.values_at(:regexp, :merges, :joins, :others)
      end
    end
  end
end
