shared_examples_for :node_to_sql do |node_sql|
  describe '#to_sql' do
    specify{ expect(described_node.to_sql).to eq(node_sql) }
  end
end
