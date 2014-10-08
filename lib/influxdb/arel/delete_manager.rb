module Influxdb
  module Arel
    class DeleteManager < TreeManager
      def initialize
        @ast = Nodes::DeleteStatement.new
      end

      def from(*new_tables, &block)
        expr = Clauses::FromClause.new(*new_tables, &block).to_arel

        case expr
        when Array
          regexps, others = separate_tables(expr.to_a)
          ast.regexp = regexps.first if regexps
          ast.tables = others
        when Regexp
          ast.regexp = expr
        else
          ast.tables = Array(expr)
        end

        self
      end

      def tables=(value)
        ast.tables = value
      end

      def regexp=(value)
        ast.regexp = value
      end

      private

      def separate_tables(expr)
        grouped_tables = expr.group_by do |value|
          case value
          when Nodes::Join, Nodes::Merge
            :filtered
          when Regexp
            :regexp
          else
            :others
          end
        end
        grouped_tables.values_at(:regexp, :others)
      end
    end
  end
end
