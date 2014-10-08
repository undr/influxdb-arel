module Influxdb
  module Arel
    module Clauses
      class WhereClause < Base
        include Expressions

        def initialize(conditions, &block)
          @conditions = build_where_expression(conditions)
          super(&block)
        end

        def a(name)
          Nodes::Attribute.new(name) #.extend(:math, :predications)
        end

        def now
          Nodes::Now.new
        end

        def method_missing(method, *args, &block)
          a(method)
        end

        def to_arel
          super{|result| [@conditions, result].flatten.compact.inject(&:and) }
        end

        protected

        def function_node(name, *args)
          args[0] = arelize(args[0]){|expr| a(expr) }
          Nodes.const_get(name, *args)
        end

        def build_where_expression(conditions)
          case conditions
          when Hash
            build_from_hash(conditions)
          when Array
            conditions.map{|expr| build_where_expression(expr) }.flatten.compact.inject(&:and)
          when TreeManager
            conditions.ast.wheres
          when String
            Arel.sql(conditions)
          else
            conditions
          end
        end

        def build_from_hash(conditions)
          conditions.each_with_object([]) do |(attribute, value), result|
            check_attribute!(attribute)
            attribute = a(attribute) unless Nodes::Attribute === attribute
            result << build_attribute_expression(attribute, value)
          end
        end

        def build_attribute_expression(attribute, value)
          case value
          when Array
            build_array_expression(attribute, value)
          when Regexp
            attribute.matches(value)
          when Range
            attribute.in(value)
          else
            attribute.eq(value)
          end
        end

        def build_array_expression(attribute, value)
          ranges, values = value.to_a.partition{|v| v.is_a?(Range) }

          values_predicate = if values.include?(nil)
            values = values.compact

            case values.length
            when 0
              attribute.eq(nil)
            when 1
              attribute.eq(values.first).or(attribute.eq(nil))
            else
              attribute.in(values).or(attribute.eq(nil))
            end
          else
            attribute.in(values)
          end

          array_predicates = ranges.map{|range| attribute.in(range) }
          array_predicates << values_predicate
          array_predicates.inject{|composite, predicate| composite.or(predicate) }
        end

        def check_attribute!(attribute)
          unless [Nodes::Attribute, String, Symbol].include?(attribute.class)
            raise 'IllegalSQLConstruct: Illegal attribute name'
          end
        end
      end
    end
  end
end
