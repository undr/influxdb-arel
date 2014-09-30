module Influxdb
  module Arel
    class SelectManager < Arel::TreeManager
      def initialize(*tables)
        super()
        @ast = Nodes::SelectStatement.new
        from(*tables)
      end

      def initialize_copy(other)
        super
      end

      def limit
        ast.limit
      end

      alias :taken :limit

      def wheres
        ast.wheres
      end

      def group(*columns)
        columns.each do |column|
          column = STRING_OR_SYMBOL_CLASS.include?(column.class) ? Arel.sql(column.to_s) : column
          ast.groups.push(Nodes::Group.new(column))
        end

        self
      end

      def fill(value)
        ast.fill = Nodes::Fill.new(value)
        self
      end

      def from(*series)
        series = series.map do |table|
          case table
          when String, Symbol
            Arel.sql(table.to_s)
          when Regexp
            Arel.sql(table.inspect)
          else
            table
          end
        end.compact

        ast.series = series unless series.empty?
        self
      end

      def join(table = nil)
        if table && !series.empty?
          table = STRING_OR_SYMBOL_CLASS.include?(table.class) ? Arel.sql(table.to_s) : table
          ast.join = Nodes::Join.new(series[0], table)
        elsif series.size > 1
          ast.join = Nodes::Join.new(series[0], series[1])
        end
        self
      end

      def merge(table = nil)
        if table && !series.empty?
          table = STRING_OR_SYMBOL_CLASS.include?(table.class) ? Arel.sql(table.to_s) : table
          ast.merge = Nodes::Merge.new(series[0].unalias, table.unalias)
        elsif series.size > 1
          ast.merge = Nodes::Merge.new(series[0].unalias, series[1].unalias)
        end
        self
      end

      def column(*columns)
        columns.each do |column|
          column = STRING_OR_SYMBOL_CLASS.include?(column.class) ? Arel.sql(column.to_s) : column
          ast.columns.push(column)
        end

        self
      end

      def columns
        ast.columns
      end

      def columns=(columns)
        self.column(*columns)
      end

      def order(expr)
        expr = STRING_OR_SYMBOL_CLASS.include?(expr.class) ? Nodes::Ordering.new(expr.to_s) : expr
        ast.order = expr
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

      def ordering
        ast.order
      end

      def take(limit)
        ast.limit = limit ? Nodes::Limit.new(limit) : nil
        self
      end

      alias :limit= :take

      def into(table)
        table = STRING_OR_SYMBOL_CLASS.include?(table.class) ? Arel.sql(table.to_s) : table
        ast.into = Nodes::Into.new(table)
        self
      end

      def series
        ast.series
      end
    end
  end
end
