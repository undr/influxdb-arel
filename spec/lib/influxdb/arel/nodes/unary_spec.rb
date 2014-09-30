require 'spec_helper'

describe Influxdb::Arel::Nodes::Unary do
  it_should_behave_like :unary_node, :Unary
end

describe Influxdb::Arel::Nodes::Group do
  it_should_behave_like :unary_node, :Group, 'value'
end

describe Influxdb::Arel::Nodes::Limit do
  it_should_behave_like :unary_node, :Limit, 'LIMIT value'
end

describe Influxdb::Arel::Nodes::Fill do
  it_should_behave_like :unary_node, :Fill, 'fill(value)'
end

describe Influxdb::Arel::Nodes::Ordering do
  it_should_behave_like :unary_node, :Ordering, 'ORDER VALUE'
end

describe Influxdb::Arel::Nodes::Into do
  it_should_behave_like :unary_node, :Into, 'INTO value'
end
