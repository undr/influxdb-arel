require 'spec_helper'

describe Influxdb::Arel::Nodes::Time do
  it_should_behave_like :unary_node, :Time, 'time(value)'
end
