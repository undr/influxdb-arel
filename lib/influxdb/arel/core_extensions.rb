class Integer
  def u
    Influxdb::Arel::Nodes::Duration.new(self, 'u')
  end

  def s
    Influxdb::Arel::Nodes::Duration.new(self, 's')
  end

  def m
    Influxdb::Arel::Nodes::Duration.new(self, 'm')
  end

  def h
    Influxdb::Arel::Nodes::Duration.new(self, 'h')
  end

  def d
    Influxdb::Arel::Nodes::Duration.new(self, 'd')
  end

  def w
    Influxdb::Arel::Nodes::Duration.new(self, 'w')
  end
end

class String
  def to_influxdb_arel
    Influxdb::Arel::Nodes::SqlLiteral.new(self)
  end

  alias :to_arel :to_influxdb_arel unless method_defined?(:to_arel)

  def as(other)
    Influxdb::Arel::Nodes::As.new(to_influxdb_arel, other.to_influxdb_arel)
  end
end

class Symbol
  def to_influxdb_arel
    Influxdb::Arel::Table.new(self.to_s)
  end

  alias :to_arel :to_influxdb_arel unless method_defined?(:to_arel)

  def as(other)
    to_influxdb_arel.as(other)
  end
end
