require 'spec_helper'

describe Influxdb::Arel::Nodes::Count do
  it_should_behave_like :function_node, :Count, 'COUNT(expression)'
end

describe Influxdb::Arel::Nodes::Sum do
  it_should_behave_like :function_node, :Sum, 'SUM(expression)'
end

describe Influxdb::Arel::Nodes::Max do
  it_should_behave_like :function_node, :Max, 'MAX(expression)'
end

describe Influxdb::Arel::Nodes::Min do
  it_should_behave_like :function_node, :Min, 'MIN(expression)'
end

describe Influxdb::Arel::Nodes::Mean do
  it_should_behave_like :function_node, :Mean, 'MEAN(expression)'
end

describe Influxdb::Arel::Nodes::Mode do
  it_should_behave_like :function_node, :Mode, 'MODE(expression)'
end

describe Influxdb::Arel::Nodes::Median do
  it_should_behave_like :function_node, :Median, 'MEDIAN(expression)'
end

describe Influxdb::Arel::Nodes::Distinct do
  it_should_behave_like :function_node, :Distinct, 'DISTINCT(expression)'
end

describe Influxdb::Arel::Nodes::Percentile do
  it_should_behave_like :function_node, :Percentile, 'PERCENTILE(expression, 99)', [99]
end

describe Influxdb::Arel::Nodes::Histogram do
  it_should_behave_like :function_node, :Histogram, 'HISTOGRAM(expression, 50)', [50]
end

describe Influxdb::Arel::Nodes::Derivative do
  it_should_behave_like :function_node, :Derivative, 'DERIVATIVE(expression)'
end

describe Influxdb::Arel::Nodes::Stddev do
  it_should_behave_like :function_node, :Stddev, 'STDDEV(expression)'
end

describe Influxdb::Arel::Nodes::First do
  it_should_behave_like :function_node, :First, 'FIRST(expression)'
end

describe Influxdb::Arel::Nodes::Last do
  it_should_behave_like :function_node, :Last, 'LAST(expression)'
end

describe Influxdb::Arel::Nodes::Difference do
  it_should_behave_like :function_node, :Difference, 'DIFFERENCE(expression)'
end

describe Influxdb::Arel::Nodes::Top do
  it_should_behave_like :function_node, :Top, 'TOP(expression, 10)', [10]
end

describe Influxdb::Arel::Nodes::Bottom do
  it_should_behave_like :function_node, :Bottom, 'BOTTOM(expression, 10)', [10]
end
