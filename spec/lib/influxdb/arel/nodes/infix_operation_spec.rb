require 'spec_helper'

describe Influxdb::Arel::Nodes::Multiplication do
  it_should_behave_like :infix_operation_node, :Multiplication, 'left * right'
end

describe Influxdb::Arel::Nodes::Division do
  it_should_behave_like :infix_operation_node, :Division, 'left / right'
end

describe Influxdb::Arel::Nodes::Addition do
  it_should_behave_like :infix_operation_node, :Addition, 'left + right'
end

describe Influxdb::Arel::Nodes::Subtraction do
  it_should_behave_like :infix_operation_node, :Subtraction, 'left - right'
end
