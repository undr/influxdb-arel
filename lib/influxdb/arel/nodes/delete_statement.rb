module Influxdb
  module Arel
    module Nodes
      class DeleteStatement < Node
        attr_accessor :wheres, :tables, :regexp

        def initialize
          super
          self.wheres = []
          self.tables = []
          self.regexp = nil
        end

        def initialize_copy(other)
          super
          self.wheres = wheres.map{|where| where.clone }
          self.tables = tables.map{|table| table.clone }
          self.regexp = regexp.clone
        end

        def table
          regexp || tables
        end

        def hash
          [wheres,  tables].hash
        end

        def eql?(other)
          self.class == other.class && wheres == other.wheres && table == other.table
        end

        alias :== :eql?
      end
    end
  end
end
