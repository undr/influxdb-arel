module Influxdb
  module Arel
    module Nodes
      class Node
        include Extensions::Boolean

        ENTENSIONS = {
          alias: :AliasPrediction,
          table_alias: :TableAliasPrediction,
          math: :Math,
          expressions: :Expressions,
          predications: :Predications
        }

        def to_sql
          Visitor.new.accept(self)
        end

        def extend(*extensions)
          extensions.each do |extension|
            if module_name = EXTENSIONS[extension]
              singleton_class.send(:include, Influxdb::Arel::Extensions.const_get(module_name))
            end
          end

          self
        end
      end
    end
  end
end
