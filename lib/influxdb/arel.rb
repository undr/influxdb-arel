require "influxdb/arel/version"

require 'influxdb/arel/expressions'
require 'influxdb/arel/predications'
require 'influxdb/arel/math'
require 'influxdb/arel/alias_predication'
require 'influxdb/arel/table'
require 'influxdb/arel/attributes'

require 'influxdb/arel/visitor'
require 'influxdb/arel/visitor/select_statement'

require 'influxdb/arel/tree_manager'
require 'influxdb/arel/select_manager'
# require 'influxdb/arel/delete_manager'
require 'influxdb/arel/nodes'

module Influxdb
  module Arel
    extend self

    def sql(raw_sql)
      Nodes::SqlLiteral.new(raw_sql)
    end

    def star
      sql('*')
    end

    def now
      Influxdb::Arel::Nodes::Now.new
    end

    def time(duration)
      duration = sql(duration) if String === duration
      Influxdb::Arel::Nodes::Time.new(duration)
    end
  end
end
