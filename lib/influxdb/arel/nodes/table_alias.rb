module Influxdb
  module Arel
    module Nodes
      class TableAlias < Binary
        include Extensions::JoiningMerging

        alias :name :right
        alias :relation :left
        alias :table_alias :name

        def table_name
          relation.respond_to?(:name) ? relation.name : name
        end

        def unalias
          relation
        end
      end
    end
  end
end
