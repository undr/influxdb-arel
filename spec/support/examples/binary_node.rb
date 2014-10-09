shared_examples_for :binary_node do |klass, node_sql = nil|
  let(:described_node){ node(klass, sql('left'), sql('right')) }

  it_should_behave_like :node_to_sql, node_sql if node_sql
  it_should_behave_like :node_boolean_predications, node_sql if node_sql

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(klass, sql('left'), sql('right')))).to be_truthy }
    specify{ expect(described_node.eql?(node(klass, sql('right'), sql('left')))).to be_falsy }
  end
end
