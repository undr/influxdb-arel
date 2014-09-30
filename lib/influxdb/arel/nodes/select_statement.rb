module Influxdb
  module Arel
    module Nodes
      class SelectStatement < Node
        attr_accessor :limit, :order, :wheres, :groups, :columns, :series, :join, :merge, :fill, :into

        def initialize
          super
          self.wheres = []
          self.groups = []
          self.columns = []
          self.series = []
          self.merge = nil
          self.join = nil
          self.order = nil
          self.limit = nil
          self.fill = nil
          self.into = nil
        end

        def initialize_copy(other)
          super
          self.wheres = wheres.map{|where| where.clone }
          self.groups = groups.map{|group| group.clone }
          self.columns = columns.map{|column| column.clone }
          self.series = series.map{|series| series.clone }
          self.join = join.clone if join
          self.merge = merge.clone if merge
          self.order = order.clone if order
          self.limit = limit.clone if limit
          self.fill = fill.clone if fill
          self.into = into.clone if into
        end

        def table
          join || merge || series.map(&:unalias).uniq
        end

        def hash
          [limit, order, wheres, groups, columns, table, fill, into].hash
        end

        def eql?(other)
          self.class == other.class &&
            columns == other.columns &&
            wheres == other.wheres &&
            groups == other.groups &&
            table == other.table &&
            order == other.order &&
            limit == other.limit &&
            fill == other.fill &&
            into == other.into
        end

        alias :== :eql?
      end
    end
  end
end
