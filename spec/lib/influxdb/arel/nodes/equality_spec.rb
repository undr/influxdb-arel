require 'spec_helper'

describe Influxdb::Arel::Nodes::Equality do
  it_should_behave_like :binary_node, :Equality, 'left = right'
end
