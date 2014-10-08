module Influxdb
  module Arel
    class Visitor
      WHERE = ' WHERE '
      SPACE = ' '
      COMMA = ', '
      GROUP_BY = ' GROUP BY '
      AND = ' AND '
      OR = ' OR '

      def accept(object)
        visit(object)
      end

      private

      DISPATCH = Hash.new do |method_hash, node_class|
        method_hash[node_class] = "visit_#{(node_class.name || '').gsub('::', '_')}"
      end

      def visit(object)
        send(DISPATCH[object.class], object)
      rescue NoMethodError => e
        raise e if respond_to?(DISPATCH[object.class], true)
        DISPATCH[object.class] = DISPATCH[find_visitable_superclass(object)]
        retry
      end

      def visit_Influxdb_Arel_Nodes_SelectStatement(object)
        SelectStatement.new(self).visit(object)
      end

      def visit_Influxdb_Arel_Nodes_DeleteStatement(object)
        DeleteStatement.new(self).visit(object)
      end

      def visit_Influxdb_Arel_Nodes_Table(object)
        quote_table_name(object.name)
      end

      def visit_Influxdb_Arel_Nodes_Join(object)
        visit_predication(object, 'INNER JOIN')
      end

      def visit_Influxdb_Arel_Nodes_Merge(object)
        visit_predication(object, 'MERGE')
      end

      def visit_Influxdb_Arel_Nodes_Limit(object)
        "LIMIT #{visit(object.expr)}"
      end

      def visit_Influxdb_Arel_Nodes_Ordering(object)
        "ORDER #{object.value.upcase}"
      end

      def visit_Influxdb_Arel_Nodes_Into(object)
        "INTO #{visit(object.expr)}"
      end

      def visit_Influxdb_Arel_Nodes_Grouping(object)
        "(#{visit(object.expr)})"
      end

      def visit_Influxdb_Arel_Nodes_Group(object)
        visit(object.expr)
      end

      def visit_Influxdb_Arel_Nodes_TableAlias(object)
        "#{visit(object.relation)} AS #{quote_table_name(object.name)}"
      end

      def function(object)
        expressions = object.expressions.map{|exp| visit(exp) }.join(COMMA)
        function_clause = object.class.name.split('::').last.upcase
        "#{function_clause}(#{expressions})"
      end

      alias :visit_Influxdb_Arel_Nodes_Count :function
      alias :visit_Influxdb_Arel_Nodes_Sum :function
      alias :visit_Influxdb_Arel_Nodes_Max :function
      alias :visit_Influxdb_Arel_Nodes_Min :function
      alias :visit_Influxdb_Arel_Nodes_Mean :function
      alias :visit_Influxdb_Arel_Nodes_Mode :function
      alias :visit_Influxdb_Arel_Nodes_Median :function
      alias :visit_Influxdb_Arel_Nodes_Distinct :function
      alias :visit_Influxdb_Arel_Nodes_Percentile :function
      alias :visit_Influxdb_Arel_Nodes_Histogram :function
      alias :visit_Influxdb_Arel_Nodes_Derivative :function
      alias :visit_Influxdb_Arel_Nodes_Stddev :function
      alias :visit_Influxdb_Arel_Nodes_First :function
      alias :visit_Influxdb_Arel_Nodes_Last :function
      alias :visit_Influxdb_Arel_Nodes_Difference :function
      alias :visit_Influxdb_Arel_Nodes_Top :function
      alias :visit_Influxdb_Arel_Nodes_Bottom :function

      def visit_Influxdb_Arel_Nodes_Fill(object)
        "fill(#{visit(object.expr)})"
      end

      def visit_Influxdb_Arel_Nodes_Time(object)
        "time(#{visit(object.expr)})"
      end

      def visit_Influxdb_Arel_Nodes_Duration(object)
        "#{object.value}#{object.suffix}"
      end

      def visit_Influxdb_Arel_Nodes_Now(object)
        "now()"
      end

      def visit_Influxdb_Arel_Nodes_In(object)
        if Array === object.right && object.right.empty?
          '1 = 0'
        else
          "#{visit(object.left)} IN (#{visit(object.right)})"
        end
      end

      def visit_Influxdb_Arel_Nodes_GreaterThanOrEqual(object)
        visit_predication(object, '>=')
      end

      def visit_Influxdb_Arel_Nodes_GreaterThan(object)
        visit_predication(object, '>')
      end

      def visit_Influxdb_Arel_Nodes_LessThanOrEqual(object)
        visit_predication(object, '<=')
      end

      def visit_Influxdb_Arel_Nodes_LessThan(object)
        visit_predication(object, '<')
      end

      def visit_Influxdb_Arel_Nodes_NotEqual(object)
        visit_predication(object, '<>')
      end

      def visit_Influxdb_Arel_Nodes_Equality(object)
        visit_predication(object, '=')
      end

      def visit_Influxdb_Arel_Nodes_Matches(object)
        visit_predication(object, '=~')
      end

      def visit_Influxdb_Arel_Nodes_DoesNotMatch(object)
        visit_predication(object, '!~')
      end

      def visit_Influxdb_Arel_Nodes_And(object)
        object.children.map{|node| visit(node) }.join(AND)
      end

      def visit_Influxdb_Arel_Nodes_Or(object)
        [visit(object.left), visit(object.right)].join(OR)
      end

      def visit_Influxdb_Arel_Nodes_As(object)
        visit_predication(object, 'AS')
      end

      def visit_Influxdb_Arel_Nodes_Attribute(object)
        # if object.relation.table_alias
        #   "#{quote_table_name(object.relation.table_alias)}.#{quote_column_name(object.name)}"
        # else
        #   quote_column_name(object.name)
        # end

        quote_column_name(object.value)
      end

      def literal(object)
        object
      end

      alias :visit_Influxdb_Arel_Nodes_SqlLiteral :literal
      alias :visit_Bignum :literal
      alias :visit_Fixnum :literal

      def quoted(object)
        quote(object)
      end

      alias :visit_ActiveSupport_Multibyte_Chars :quoted
      alias :visit_ActiveSupport_StringInquirer :quoted
      alias :visit_BigDecimal :quoted
      alias :visit_Class :quoted
      alias :visit_Date :quoted
      alias :visit_DateTime :quoted
      alias :visit_FalseClass :quoted
      alias :visit_Float :quoted
      alias :visit_Hash :quoted
      alias :visit_NilClass :quoted
      alias :visit_String :quoted
      alias :visit_Symbol :quoted
      alias :visit_Time :quoted
      alias :visit_TrueClass :quoted
      alias :visit_Regexp :quoted

      def visit_Influxdb_Arel_Nodes_InfixOperation(object)
        visit_predication(object, object.operator)
      end

      alias :visit_Influxdb_Arel_Nodes_Addition :visit_Influxdb_Arel_Nodes_InfixOperation
      alias :visit_Influxdb_Arel_Nodes_Subtraction :visit_Influxdb_Arel_Nodes_InfixOperation
      alias :visit_Influxdb_Arel_Nodes_Multiplication :visit_Influxdb_Arel_Nodes_InfixOperation
      alias :visit_Influxdb_Arel_Nodes_Division :visit_Influxdb_Arel_Nodes_InfixOperation

      def visit_Array(object)
        object.map{|node| visit(node) }.join(COMMA)
      end

      def visit_predication(object, expression)
        "#{visit(object.left)} #{expression} #{visit(object.right)}"
      end

      def quote(value)
        Quoter.quote(value)
      end

      def quote_table_name(name)
        return name if Nodes::SqlLiteral === name
        return name.inspect if Regexp === name
        /(?!\.)[\W\s]+/.match(name.to_s) ? "\"#{name}\"" : name
      end

      def quote_column_name(name)
        name
      end

      def find_visitable_superclass(object)
        object.class.ancestors.find{|klass|
          respond_to?(DISPATCH[klass], true)
        }.tap do |superklass|
          raise(TypeError, "Cannot visit #{object.class}") unless superklass
        end
      end
    end
  end
end
