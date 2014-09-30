shared_examples_for :function_node do |klass, node_sql, args = []|
  let(:expressions){ args.dup.unshift(sql('expression')) }
  let(:other_expressions){ args.dup.unshift(sql('another_expression')) }
  let(:described_node){ node(klass, expressions) }

  it_should_behave_like :node_to_sql, node_sql
  it_should_behave_like :node_as, node_sql
  it_should_behave_like :node_math, node_sql

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(klass, expressions))).to be_truthy }
    specify{ expect(described_node.eql?(node(klass, other_expressions))).to be_falsy }
  end
end
