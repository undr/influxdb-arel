module Influxdb
  module Arel
    module Nodes
      class SelectStatement < Node
        attr_accessor :limit, :order, :wheres, :groups, :attributes, :tables, :join, :merge, :regexp, :fill, :into

        def initialize
          super
          self.wheres = []
          self.groups = []
          self.attributes = []
          self.tables = []
          self.regexp = nil
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
          self.attributes = attributes.map{|attribute| attribute.clone }
          self.tables = tables.map{|table| table.clone }
          self.join = join.clone if join
          self.merge = merge.clone if merge
          self.regexp = regexp.clone if regexp
          self.order = order.clone if order
          self.limit = limit.clone if limit
          self.fill = fill.clone if fill
          self.into = into.clone if into
        end

        def table
          join || merge || regexp || tables.map(&:unalias).uniq
        end

        def hash
          [limit, order, wheres, groups, attributes, table, fill, into].hash
        end

        def eql?(other)
          self.class == other.class &&
            attributes == other.attributes &&
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
