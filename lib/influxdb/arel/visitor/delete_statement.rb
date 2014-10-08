module Influxdb
  module Arel
    class Visitor
      class DeleteStatement
        attr_reader :visitor

        def initialize(visitor)
          @visitor = visitor
        end

        def visit(object)
          build_from(object)
          build_wheres(object)

          result.strip
        end

        private

        def build_from(object)
          result << " FROM #{visitor.accept(object.table)}"
        end

        def build_wheres(object)
          unless object.wheres.empty?
            result << WHERE
            result << object.wheres.map{|where| visitor.accept(where) }.join(AND)
          end
        end

        def result
          @result ||= 'DELETE'
        end
      end
    end
  end
end
