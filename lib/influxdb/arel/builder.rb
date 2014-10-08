module Influxdb
  module Arel
    class Builder
      attr_accessor :default_table

      def initialize(default_table = nil)
        @default_table = default_table
      end

      # Specify tables for query
      #
      #   builder = Influxdb::Arel::Builder.new
      #   builder.from(:table1).to_sql
      #   => SELECT * FROM table1
      #
      #   builder = Influxdb::Arel::Builder.new
      #   builder.from{ table1.as(:alias1).join(table2.as(:alias2)) }.to_sql
      #   => SELECT * FROM table1 AS alias1 INNER JOIN table2 AS alias2
      #
      #   builder = Influxdb::Arel::Builder.new
      #   builder.from(/.*/).to_sql
      #   => SELECT * FROM /.*/
      #
      # See: <tt>Influxdb::Arel::SelectManager#from</tt>
      #
      def from(*tables, &block)
        SelectManager.new(*tables, &block)
      end

      # Merging of two tables into one.
      #
      # Tt will merge default table from builder with given table if <tt>tables</tt> contains one table.
      #
      #   builder = Influxdb::Arel::Builder.new(:table1)
      #   builder.merge(:table2).to_sql
      #   => SELECT * FROM table1 MERGE table2
      #
      # It will merge tables if <tt>tables</tt> contains two tables.
      #
      #   builder = Influxdb::Arel::Builder.new
      #   builder.merge(:table1, :table2).to_sql
      #   => SELECT * FROM table1 MERGE table2
      #
      # It will raise exception if <tt>table</tt> is nil and tables list contains only one table.
      #
      #   builder.merge.to_sql
      #   => IllegalSQLConstruct: Ambiguous merging clause
      #
      # See: <tt>Influxdb::Arel::SelectManager#merge</tt>
      #
      def merge(*tables)
        from(default_table).merge(*tables)
      end

      # Joining of two tables into one.
      #
      # It will join default table from builder with given table if <tt>tables</tt> contains one table.
      #
      #   builder = Influxdb::Arel::Builder.new(:table1)
      #   builder.join(:table2).to_sql
      #   => SELECT * FROM table1 INNER JOIN table2
      #
      # It will join tables if <tt>tables</tt> contains two tables.
      #
      #   builder = Influxdb::Arel::Builder.new
      #   builder.join(:table1, :table2).to_sql
      #   => SELECT * FROM table1 INNER JOIN table2
      #
      # It will raise exception if <tt>table</tt> is nil and tables list contains only one table.
      #
      #   builder.join.to_sql
      #   => IllegalSQLConstruct: Ambiguous merging clause
      #
      # See: <tt>Influxdb::Arel::SelectManager#join</tt>
      #
      def join(*tables)
        from(default_table).join(*tables)
      end

      # Grouping results by specified attributes or expressions, such as <tt>time(10m)</tt>
      #
      #   builder = Influxdb::Arel::Builder.new(:table)
      #   builder.group{ time(10.s), host }.to_sql
      #   => SELECT * FROM table GROUP BY time(10m), host
      #
      # If you want to fill intervals with no data you shoult call <tt>fill</tt> method after grouping:
      #
      #   builder.group{ time(10.s), host }.fill(0).to_sql
      #   => SELECT * FROM table GROUP BY time(10m), host fill(0)
      #
      # See: <tt>Influxdb::Arel::SelectManager#group</tt>
      #
      def group(*attributes, &block)
        from(default_table).group(*attributes, &block)
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
      #   builder = Influxdb::Arel::Builder.new(:table)
      #   builder.order(:desc).to_sql
      #   builder.order('desc').to_sql
      #   => SELECT * FROM table ORDER DESC
      #
      #   builder.order(:asc).to_sql
      #   builder.order('asc').to_sql
      #   => SELECT * FROM table ORDER ASC
      #
      # See: <tt>Influxdb::Arel::SelectManager#order</tt>
      #
      def order(expr)
        from(default_table).order(expr)
      end

      # Results will be sorted by ascending order.
      #
      #   builder = Influxdb::Arel::Builder.new(:table)
      #   builder.asc.to_sql
      #   => SELECT * FROM table ORDER ASC
      #
      def asc
        from(default_table).asc
      end

      # Results will be sorted by descending order.
      #
      #   builder = Influxdb::Arel::Builder.new(:table)
      #   builder.desc.to_sql
      #   => SELECT * FROM table ORDER DESC
      #
      def desc
        from(default_table).desc
      end

      # Specify conditions for selection or deletion query
      # Example:
      #
      #   builder = Influxdb::Arel::Builder.new(:table)
      #   builder.where(name: 'Undr').to_sql
      #   => SELECT * FROM table WHERE name = 'Undr'
      #
      #   builder.where(name: 'Undr'){ time.lt(10.h.ago) }.to_sql
      #   => SELECT * FROM table WHERE name = 'Undr' AND time < (now() - 10h)
      #
      #   builder.where{ name.eq('Undr').or(name.eq('Andrei')) }.to_sql
      #   => SELECT * FROM table WHERE name = 'Undr' OR name = 'Andrei'
      #
      # See: <tt>Influxdb::Arel::SelectManager#where</tt>
      #
      def where(conditions = nil, &block)
        from(default_table).where(conditions, &block)
      end

      # Specify attributes or expressions for select.
      # Example:
      #
      #   builder = Influxdb::Arel::Builder.new(:cpu_load)
      #   builder.to_sql
      #   => SELECT * FROM cpu_load
      #
      #   builder.select(:idle){ (system + user).as(:sum) }.to_sql
      #   => SELECT idle, (system + user) AS sum FROM cpu_load
      #
      #   builder.select{ [mean(idle).as(:idle_mean), mean(user).as(:user_mean)] }.to_sql
      #   => SELECT MEAN(idle) AS idle_mean, MEAN(user) AS user_mean FROM cpu_load
      #
      # See: <tt>Influxdb::Arel::SelectManager#select</tt>
      #
      def select(*attributes, &block)
        from(default_table).select(*attributes, &block)
      end

      # Set limit for result's points
      # Example:
      #
      #   builder = Influxdb::Arel::Builder.new(:table)
      #   builder.limit(100).to_sql
      #   => SELECT * FROM table LIMIT 100
      #
      def limit(amount)
        from(default_table).limit(amount)
      end

      # Create <tt>Influxdb::Arel::SelectManager</tt>
      #
      def select_manager
        SelectManager.new(default_table)
      end

      def hash
        @default_table.hash
      end

      def eql?(other)
        self.class == other.class && self.name == other.name
      end

      alias :== :eql?
    end
  end
end
