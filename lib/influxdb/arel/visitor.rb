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

      def visit(object, attribute = nil)
        send DISPATCH[object.class], object, attribute
      rescue NoMethodError => e
        raise e if respond_to?(DISPATCH[object.class], true)

        superklass = object.class.ancestors.find{|klass|
          respond_to?(DISPATCH[klass], true)
        }
        raise(TypeError, "Cannot visit #{object.class}") unless superklass

        DISPATCH[object.class] = DISPATCH[superklass]
        retry
      end

      def visit_Influxdb_Arel_Nodes_SelectStatement(object, attribute)
        result = 'SELECT'

        unless object.columns.empty?
          result << SPACE
          result << object.columns.map{|column| visit(column, attribute) }.join(COMMA)
        else
          result << SPACE
          result << Arel.star
        end

        result << " FROM #{visit(object.table, attribute)}"

        unless object.wheres.empty?
          result << WHERE
          result << object.wheres.map{|where| visit(where, attribute) }.join(AND)
        end

        unless object.groups.empty?
          result << GROUP_BY
          result << object.groups.map{|group| visit(group, attribute) }.join(COMMA)
          result << " #{visit(object.fill, attribute)}" if object.fill
        end

        result << " #{visit(object.order, attribute)}" if object.order
        result << " #{visit(object.limit, attribute)}" if object.limit
        result << " #{visit(object.into, attribute)}" if object.into

        result.strip!
        result
      end

      def visit_Influxdb_Arel_Table(object, attribute)
        quote_table_name(object.name)
      end

      def visit_Influxdb_Arel_Nodes_Join(object, attribute)
        "#{visit(object.left, attribute)} INNER JOIN #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_Merge(object, attribute)
        "#{visit(object.left, attribute)} MERGE #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_Limit(object, attribute)
        "LIMIT #{visit(object.expr, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_Ordering(object, attribute)
        "ORDER #{object.value.upcase}"
      end

      def visit_Influxdb_Arel_Nodes_Into(object, attribute)
        "INTO #{visit(object.expr, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_Grouping(object, attribute)
        "(#{visit(object.expr, attribute)})"
      end

      def visit_Influxdb_Arel_Nodes_Group(object, attribute)
        visit(object.expr, attribute)
      end

      def visit_Influxdb_Arel_Nodes_TableAlias(object, attribute)
        "#{visit(object.relation, attribute)} AS #{quote_table_name(object.name)}"
      end

      def function(object, attribute)
        expressions = object.expressions.map{|exp| visit(exp, attribute) }.join(COMMA)
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

      def visit_Influxdb_Arel_Nodes_Fill(object, attribute)
        "fill(#{visit(object.expr, attribute)})"
      end

      def visit_Influxdb_Arel_Nodes_Time(object, attribute)
        "time(#{visit(object.expr, attribute)})"
      end

      def visit_Influxdb_Arel_Nodes_Duration(object, attribute)
        "#{object.value}#{object.suffix}"
      end

      def visit_Influxdb_Arel_Nodes_Now(object, attribute)
        "now()"
      end

      def visit_Influxdb_Arel_Nodes_In(object, attribute)
        if Array === object.right && object.right.empty?
          '1 = 0'
        else
          attribute = object.left if Arel::Attributes::Attribute === object.left
          "#{visit(object.left, attribute)} IN (#{visit(object.right, attribute)})"
        end
      end

      def visit_Influxdb_Arel_Nodes_GreaterThanOrEqual(object, attribute)
        attribute = object.left if Attributes::Attribute === object.left
        "#{visit(object.left, attribute)} >= #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_GreaterThan(object, attribute)
        attribute = object.left if Attributes::Attribute === object.left
        "#{visit(object.left, attribute)} > #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_LessThanOrEqual(object, attribute)
        attribute = object.left if Attributes::Attribute === object.left
        "#{visit(object.left, attribute)} <= #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_LessThan(object, attribute)
        attribute = object.left if Attributes::Attribute === object.left
        "#{visit(object.left, attribute)} < #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_NotEqual(object, attribute)
        right = object.right
        attribute = object.left if Attributes::Attribute === object.left

        if right.nil?
          "#{visit(object.left, attribute)} <> null"
        else
          "#{visit(object.left, attribute)} <> #{visit(right, attribute)}"
        end
      end

      def visit_Influxdb_Arel_Nodes_Equality(object, attribute)
        right = object.right
        attribute = object.left if Attributes::Attribute === object.left

        if right.nil?
          "#{visit(object.left, attribute)} = null"
        else
          "#{visit(object.left, attribute)} = #{visit(right, attribute)}"
        end
      end

      def visit_Influxdb_Arel_Nodes_Matches(object, attribute)
        attribute = object.left if Attributes::Attribute === object.left
        "#{visit object.left, attribute} =~ #{visit object.right, attribute}"
      end

      def visit_Influxdb_Arel_Nodes_DoesNotMatch(object, attribute)
        attribute = object.left if Attributes::Attribute === object.left
        "#{visit(object.left, attribute)} !~ #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Nodes_And(object, attribute)
        object.children.map{|node| visit(node, attribute) }.join(AND)
      end

      def visit_Influxdb_Arel_Nodes_Or(object, attribute)
        [visit(object.left, attribute), visit(object.right, attribute)].join(OR)
      end

      def visit_Influxdb_Arel_Nodes_As(object, attribute)
        "#{visit(object.left, attribute)} AS #{visit(object.right, attribute)}"
      end

      def visit_Influxdb_Arel_Attributes_Attribute(object, attribute)
        if object.relation.table_alias
          "#{quote_table_name(object.relation.table_alias)}.#{quote_column_name(object.name)}"
        else
          quote_column_name(object.name)
        end
      end

      def literal(object, attribute)
        object
      end

      alias :visit_Influxdb_Arel_Nodes_SqlLiteral :literal
      alias :visit_Bignum :literal
      alias :visit_Fixnum :literal

      def quoted(object, attribute)
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

      def visit_Influxdb_Arel_Nodes_InfixOperation(object, attribute)
        "#{visit(object.left, attribute)} #{object.operator} #{visit(object.right, attribute)}"
      end

      alias :visit_Influxdb_Arel_Nodes_Addition :visit_Influxdb_Arel_Nodes_InfixOperation
      alias :visit_Influxdb_Arel_Nodes_Subtraction :visit_Influxdb_Arel_Nodes_InfixOperation
      alias :visit_Influxdb_Arel_Nodes_Multiplication :visit_Influxdb_Arel_Nodes_InfixOperation
      alias :visit_Influxdb_Arel_Nodes_Division :visit_Influxdb_Arel_Nodes_InfixOperation

      def visit_Array(object, attribute)
        object.map{|node| visit(node, attribute) }.join(COMMA)
      end

      def quote(value)
        return value if Arel::Nodes::SqlLiteral === value
        attribute_for(value).encode(value)
      end

      def quote_table_name(name)
        return name if Arel::Nodes::SqlLiteral === name
        return name.inspect if Regexp === name
        /(?!\.)[\W\s]+/.match(name.to_s) ? "\"#{name}\"" : name
      end

      def quote_column_name(name)
        name
      end

      def attribute_for(value)
        Influxdb::Arel::Attributes.const_get(value.class.name, false)
      rescue
        Influxdb::Arel::Attributes::Attribute
      end
    end
  end
end
