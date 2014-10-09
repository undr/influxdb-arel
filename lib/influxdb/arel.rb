require "influxdb/arel/version"
require 'influxdb/arel/core_extensions'
require 'influxdb/arel/extensions'
require 'influxdb/arel/clauses'
require 'influxdb/arel/builder'

require 'influxdb/arel/visitor'
require 'influxdb/arel/visitor/where_statement'
require 'influxdb/arel/visitor/select_statement'
require 'influxdb/arel/visitor/delete_statement'

require 'influxdb/arel/tree_manager'
require 'influxdb/arel/select_manager'
require 'influxdb/arel/delete_manager'
require 'influxdb/arel/nodes'
require 'influxdb/arel/quoter'

module Influxdb
  module Arel
    extend self

    STRING_OR_SYMBOL_CLASS = [Symbol, String]

    def sql(raw_sql)
      Nodes::SqlLiteral.new(raw_sql.to_s)
    end

    def star
      sql('*')
    end

    def arelize(expr, &block)
      block ||= ->(e){ Arel.sql(e.to_s) }

      case expr
      when Array
        expr.map{|value| arelize(value, &block) }.compact
      when Hash
        # TODO: Needs to convert Hash into sql node
      when *STRING_OR_SYMBOL_CLASS
        block.call(expr)
      else
        expr
      end
    end
  end
end
