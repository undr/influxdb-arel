module Influxdb
  module Arel
    module Extensions
      module JoiningMerging
        def join(table)
          Nodes::Join.new(self, table_arelize(table))
        end

        def merge(table)
          Nodes::Merge.new(self, table_arelize(table))
        end

        private

        def table_arelize(table)
          Arel.arelize(table){|expr| Nodes::Table.new(expr) }
        end
      end
    end
  end
end
