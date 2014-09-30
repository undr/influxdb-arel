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
        @ast = @ast.clone
      end

      def where(expr)
        expr = expr.ast if TreeManager === expr
        expr = Arel.sql(expr) if String === expr

        ast.wheres << expr
        self
      end
    end
  end
end
