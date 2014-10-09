module Influxdb
  module Arel
    class Visitor
      module WhereStatement
        def build_wheres(object)
          unless object.wheres.empty?
            result << WHERE
            result << object.wheres.map{|where| visitor.accept(where) }.join(AND)
          end
        end
      end
    end
  end
end
