require 'spec_helper'

describe Influxdb::Arel::Nodes::Table do
  let(:described_node){ node(:Table, 'value') }

  it_should_behave_like :unary_node, :Table, 'value'
  it_should_behave_like :node_joining_merging, 'value'
end
