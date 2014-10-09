require 'spec_helper'

describe Influxdb::Arel::Nodes::And do
  let(:described_node){ node(:And, ['first', sql('second'), 'third']) }

  it_should_behave_like :node_to_sql, "'first' AND second AND 'third'"
  it_should_behave_like :node_boolean_predications, "'first' AND second AND 'third'"

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(:And, ['first', sql('second'), 'third']))).to be_truthy }
    specify{ expect(described_node.eql?(node(:And, ['first', 'second', 'third']))).to be_truthy }
    specify{ expect(described_node.eql?(node(:And, ['first', 'second', 'third', 'fourth']))).to be_falsy }
  end
end
