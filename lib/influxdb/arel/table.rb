module Influxdb
  module Arel
    class Table
      class << self
        def comparable_classes
          [Influxdb::Arel::Table, Influxdb::Arel::Nodes::SqlLiteral]
        end
      end

      attr_accessor :name

      alias :table_name :name

      def initialize(name)
        @name = name.to_s
      end

      # Specify alias for table
      # Example:
      #
      #   Influxdb::Arel::Table.new('table').as('alias_table').to_sql
      #   => table AS alias_table
      #
      def alias(name)
        Nodes::TableAlias.new(self, name)
      end

      alias :as :alias

      def from(*tables)
        SelectManager.new(*tables)
      end

      # Merging of two series into one.
      #
      # If <tt>table</tt> is nil it will merge two first tables from tables list.
      #
      #   table = Influxdb::Arel::Table.new('table')
      #   table.from('table1', 'table2').merge.to_sql
      #   => SELECT * FROM table1 MERGE table2
      #
      # If <tt>table</tt> is nil and tables list contains only one table it will change nothing.
      #
      #   table.merge.to_sql
      #   => SELECT * FROM table
      #
      # If <tt>table</tt> exists it will merge first table from tables list with given table.
      #
      #   table.merge('table2').to_sql
      #   => SELECT * FROM table MERGE table2
      #
      #   table.from('table1', 'table2').merge('table3').to_sql
      #   => SELECT * FROM table1 MERGE table3
      #
      def merge(table = nil)
        from(self).merge(table)
      end

      # Joining of two series.
      #
      # If <tt>table</tt> is nil it will join two first tables from tables list.
      #
      #   table = Influxdb::Arel::Table.new('table')
      #   table.from('table1', 'table2').join.to_sql
      #   => SELECT * FROM table1 INNER JOIN table2
      #
      # If <tt>table</tt> is nil and tables list contains only one table it will change nothing.
      #
      #   table.join.to_sql
      #   => SELECT * FROM table
      #
      # If <tt>table</tt> exists it will join first table from tables list with given table.
      #
      #   table.join('table2').to_sql
      #   => SELECT * FROM table INNER JOIN table2
      #
      #   table.from('table1', 'table2').join('table3').to_sql
      #   => SELECT * FROM table1 INNER JOIN table3
      #
      # Aliases.
      # You can define alias for each joined table. It would be usefull for self joining table.
      #
      #   table.from(table.as(:table_one)).join(table.as(:table_two)).to_sql
      #   => SELECT * FROM table AS table_one INNER JOIN table AS table_two
      #
      def join(table = nil)
        from(self).join(table)
      end

      # Grouping results by specified columns or expressions, such as <tt>time(10m)</tt>
      #
      #   table = Influxdb::Arel::Table.new('table')
      #   table.group(table.time(10.m), table[:host]).to_sql
      #   => SELECT * FROM table GROUP BY time(10m), host
      #
      # If you want to fill intervals with no data you shoult call <tt>fill</tt> method after:
      #
      #   table.group(10.m.time, table[:host]).fill(0).to_sql
      #   => SELECT * FROM table GROUP BY time(10m), host fill(0)
      #
      def group(*columns)
        from(self).group(*columns)
      end

      # Set the ordering of results
      # Possible values:
      #
      # * <tt>:asc</tt>
      #   Default value. Results will be sorted by ascending order.
      #
      # * <tt>:desc</tt>
      #   Default value. Results will be sorted by descending order.
      #
      # Example:
      #
      #   table = Influxdb::Arel::Table.new('table')
      #   table.order(:desc).to_sql
      #   table.order('desc').to_sql
      #   => SELECT * FROM table ORDER DESC
      #
      #   table.order(:asc).to_sql
      #   table.order('asc').to_sql
      #   => SELECT * FROM table ORDER ASC
      #
      def order(expr)
        from(self).order(expr)
      end

      # Specify conditions for selection or deletion query
      # Example:
      #
      #   table = Influxdb::Arel::Table.new('table')
      #   table.where(table[:name].eq('Undr')).to_sql
      #   => SELECT * FROM table WHERE name = 'Undr'
      #
      #   table.where(table[:name].eq('Undr')).where(table[:time].lt(10.h.ago).to_sql
      #   => SELECT * FROM table WHERE name = 'Undr' AND time < (now() - 10h)
      #
      #   table.where(table[:name].eq('Undr').or(table[:name].eq('Andrei'))).to_sql
      #   => SELECT * FROM table WHERE name = 'Undr' OR name = 'Andrei'
      #
      def where(condition)
        from(self).where(condition)
      end

      # Specify columns or expressions for select.
      # Example:
      #
      #   table = Influxdb::Arel::Table.new('cpu_load')
      #   table.to_sql
      #   => SELECT * FROM cpu_load
      #
      #   table.column((table[:system] + table[:user]).as(:sum)).to_sql
      #   => SELECT (system + user) AS sum FROM cpu_load
      #
      #   table.column(table[:idle].mean.as(:idle_mean), table[:user].mean.as(:user_mean)).to_sql
      #   => SELECT MEAN(idle) AS idle_mean, MEAN(user) AS user_mean FROM cpu_load
      #
      def column(*things)
        from(self).column(*things)
      end

      # Set limit for result's points
      # Example:
      #
      #   table = Influxdb::Arel::Table.new('cpu_load')
      #   table.take(100).to_sql
      #   => SELECT * FROM table LIMIT 100
      #
      def take(amount)
        from(self).take(amount)
      end

      # Get attribute
      #
      def [](name)
        Attribute.new(self, name)
      end

      def select_manager
        SelectManager.new
      end

      def hash
        @name.hash
      end

      def eql?(other)
        self.class.comparable_classes.include?(self.class) && self.name == other.name
      end

      alias :== :eql?

      def table_alias
        nil
      end

      def unalias
        self
      end

      def sql(raw_sql)
        Arel.sql(raw_sql)
      end

      def star
        Arel.star
      end

      def now
        Arel.now
      end

      def time(duration)
        Arel.time(duration)
      end
    end
  end
end
