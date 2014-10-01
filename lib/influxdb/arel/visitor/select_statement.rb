module Influxdb
  module Arel
    class Visitor
      class SelectStatement
        attr_reader :visitor

        def initialize(visitor)
          @visitor = visitor
        end

        def visit(object)
          build_columns(object)
          build_from(object)
          build_wheres(object)
          build_groups(object)

          result << " #{visitor.accept(object.order)}" if object.order
          result << " #{visitor.accept(object.limit)}" if object.limit
          result << " #{visitor.accept(object.into)}" if object.into

          result.strip
        end

        private

        def build_columns(object)
          unless object.columns.empty?
            result << SPACE
            result << object.columns.map{|column| visitor.accept(column) }.join(COMMA)
          else
            result << SPACE
            result << Arel.star
          end
        end

        def build_from(object)
          result << " FROM #{visitor.accept(object.table)}"
        end

        def build_wheres(object)
          unless object.wheres.empty?
            result << WHERE
            result << object.wheres.map{|where| visitor.accept(where) }.join(AND)
          end
        end

        def build_groups(object)
          unless object.groups.empty?
            result << GROUP_BY
            result << object.groups.map{|group| visitor.accept(group) }.join(COMMA)
            result << " #{visitor.accept(object.fill)}" if object.fill
          end
        end

        def result
          @result ||= 'SELECT'
        end
      end
    end
  end
end
