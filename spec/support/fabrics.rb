module Influxdb
  module Arel
    module RspecHelper
      def sql(value)
        node('SqlLiteral', value)
      end

      def node(class_name, *args)
        Influxdb::Arel::Nodes.const_get(class_name).new(*args)
      end

      def table(name)
        Influxdb::Arel::Table.new(name)
      end

      def visitor
        Influxdb::Arel::Visitor.new
      end
    end
  end
end
