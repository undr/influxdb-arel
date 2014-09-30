require 'spec_helper'

describe Influxdb::Arel::Nodes::SqlLiteral do
  let(:described_node){ node(:SqlLiteral, 'expressions') }

  describe '#to_sql' do
    specify{ expect(visitor.accept(described_node)).to eq('expressions') }
  end

  it_should_behave_like :node_as, 'expressions'
  it_should_behave_like :node_expressions, 'expressions'
  it_should_behave_like :node_predications, 'expressions'

  describe '#name' do
    specify{ expect(described_node.name).to eq(described_node) }
  end

  describe '#unalias' do
    specify{ expect(described_node.unalias).to eq(described_node) }
  end

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(:SqlLiteral, 'expressions'))).to be_truthy }
    specify{ expect(described_node.eql?(table('expressions'))).to be_truthy }
    specify{ expect(described_node.eql?(node(:SqlLiteral, 'expressions1'))).to be_falsy }
    specify{ expect(described_node.eql?(node(:Fill, 'expressions'))).to be_falsy }
  end
end
