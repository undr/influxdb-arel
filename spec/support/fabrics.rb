module Influxdb
  module Arel
    module RspecHelper
      def sql(value)
        node('SqlLiteral', value.to_s)
      end

      def node(class_name, *args)
        Influxdb::Arel::Nodes.const_get(class_name).new(*args)
      end

      def builder(name = nil)
        Influxdb::Arel::Builder.new(name)
      end

      def visitor
        Influxdb::Arel::Visitor.new
      end
    end
  end
end
