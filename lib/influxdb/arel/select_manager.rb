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
        if attributes.empty? && !block_given?
          ast.groups = nil
        else
          ast.groups = Clauses::GroupClause.new(*attributes, &block).to_arel
        end

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
        if attributes.empty? && !block_given?
          ast.attributes = nil
        else
          ast.attributes = Clauses::SelectClause.new(*attributes, &block).to_arel
        end

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
        joining_tables = (ast.tables + joining_tables).compact
        raise 'IllegalSQLConstruct: Ambiguous joining clause' if joining_tables.size != 2
        joining_tables = Arel.arelize(joining_tables){|expr| Nodes::Table.new(expr) }
        ast.join = Nodes::Join.new(*joining_tables)
        self
      end

      def merge(*merging_tables)
        merging_tables = (ast.tables + merging_tables).compact
        raise 'IllegalSQLConstruct: Ambiguous merging clause' if merging_tables.size != 2
        merging_tables = Arel.arelize(merging_tables){|expr| Nodes::Table.new(expr) }
        ast.merge = Nodes::Merge.new(*merging_tables)
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
