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

class Object
  def safe_clone
    self.clone
  rescue TypeError => e
    self
  end
end
