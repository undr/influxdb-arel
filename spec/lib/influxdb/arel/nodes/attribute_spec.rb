require 'spec_helper'

describe Influxdb::Arel::Nodes::Attribute do
  let(:described_node){ node(:Attribute, 'value') }

  it_should_behave_like :unary_node, :Attribute, 'value'
  it_should_behave_like :node_as, 'value'
  it_should_behave_like :node_expressions, 'value'
  it_should_behave_like :node_predications, 'value'
  it_should_behave_like :node_math, 'value'
end
