shared_examples_for :unary_node do |klass, node_sql = nil|
  let(:described_node){ node(klass, sql('value')) }

  it_should_behave_like :node_to_sql, node_sql if node_sql
  it_should_behave_like :node_boolean_predications, node_sql if node_sql

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(klass, sql('value')))).to be_truthy }
    specify{ expect(described_node.eql?(node(klass, sql('another value')))).to be_falsy }
  end
end
