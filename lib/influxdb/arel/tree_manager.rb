module Influxdb
  module Arel
    class TreeManager
      STRING_OR_SYMBOL_CLASS = [Symbol, String]

      attr_reader :ast

      def visitor
        Visitor.new
      end

      def to_sql
        visitor.accept(ast)
      end

      def initialize_copy(other)
        super
        @ast = ast.clone
      end

      def where(expr = nil, &block)
        ast.wheres << Clauses::WhereClause.new(expr, &block).to_arel
        self
      end

      def where!(expr = nil, &block)
        ast.wheres = [Clauses::WhereClause.new(expr, &block).to_arel].compact
        self
      end

      def where_values
        ast.wheres
      end

      def where_values=(value)
        ast.wheres = value
      end
    end
  end
end
