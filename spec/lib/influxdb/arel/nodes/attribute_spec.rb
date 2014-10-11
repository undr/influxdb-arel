require 'spec_helper'

describe Influxdb::Arel::Nodes::Attribute do
  let(:described_node){ node(:Attribute, 'value') }

  it_should_behave_like :unary_node, :Attribute, 'value'
  it_should_behave_like :node_as, 'value'
  it_should_behave_like :node_expressions, 'value'
  it_should_behave_like :node_predications, 'value'
  it_should_behave_like :node_math, 'value'

  describe '#time?' do
    specify{ expect(node(:Attribute, 'value').time?).to be_falsy }
    specify{ expect(node(:Attribute, 'time').time?).to be_truthy }
  end

  describe '#sequence_number?' do
    specify{ expect(node(:Attribute, 'value').sequence_number?).to be_falsy }
    specify{ expect(node(:Attribute, 'sequence_number').sequence_number?).to be_truthy }
  end
end
