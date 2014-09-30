require 'spec_helper'

describe Influxdb::Arel::Nodes::Binary do
  it_should_behave_like :binary_node, :Binary
end

describe Influxdb::Arel::Nodes::As do
  it_should_behave_like :binary_node, :As, 'left AS right'
end

describe Influxdb::Arel::Nodes::DoesNotMatch do
  it_should_behave_like :binary_node, :DoesNotMatch, 'left !~ right'
end

describe Influxdb::Arel::Nodes::GreaterThan do
  it_should_behave_like :binary_node, :GreaterThan, 'left > right'
end

describe Influxdb::Arel::Nodes::GreaterThanOrEqual do
  it_should_behave_like :binary_node, :GreaterThanOrEqual, 'left >= right'
end

describe Influxdb::Arel::Nodes::Join do
  it_should_behave_like :binary_node, :Join, 'left INNER JOIN right'
end

describe Influxdb::Arel::Nodes::LessThan do
  it_should_behave_like :binary_node, :LessThan, 'left < right'
end

describe Influxdb::Arel::Nodes::LessThanOrEqual do
  it_should_behave_like :binary_node, :LessThanOrEqual, 'left <= right'
end

describe Influxdb::Arel::Nodes::Matches do
  it_should_behave_like :binary_node, :Matches, 'left =~ right'
end

describe Influxdb::Arel::Nodes::Merge do
  it_should_behave_like :binary_node, :Merge, 'left MERGE right'
end

describe Influxdb::Arel::Nodes::NotEqual do
  it_should_behave_like :binary_node, :NotEqual, 'left <> right'
end

describe Influxdb::Arel::Nodes::Or do
  it_should_behave_like :binary_node, :Or, 'left OR right'
end
