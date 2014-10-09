shared_examples_for :infix_operation_node do |klass, node_sql|
  let(:described_node){ node(klass, sql('left'), sql('right')) }

  it_should_behave_like :binary_node, klass, node_sql
  it_should_behave_like :node_expressions, node_sql
  it_should_behave_like :node_predications, node_sql
  it_should_behave_like :node_math, node_sql

  describe '#as' do
    subject{ described_node.as(:alias) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::As) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql}) AS alias") }
  end
end
