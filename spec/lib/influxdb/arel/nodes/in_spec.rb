require 'spec_helper'

describe Influxdb::Arel::Nodes::In do
  let(:described_node){ node(:In, sql('left'), [1, 2, 3]) }

  it_should_behave_like :node_to_sql, 'left IN (1, 2, 3)'
  it_should_behave_like :node_boolean_predications, 'left IN (1, 2, 3)'

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(:In, sql('left'), [1, 2, 3]))).to be_truthy }
    specify{ expect(described_node.eql?(node(:In, sql('left'), [1, 2]))).to be_falsy }
    specify{ expect(described_node.eql?(node(:In, sql('left1'), [1, 2, 3]))).to be_falsy }
  end
end
