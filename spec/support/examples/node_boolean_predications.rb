shared_examples_for :node_boolean_predications do |node_sql|
  describe '#and' do
    let(:another_node){ sql('node') }

    subject{ described_node.and(another_node) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::And) }
    specify{ expect(subject.children).to eq([described_node, another_node]) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} AND node") }
  end

  describe '#or' do
    let(:another_node){ sql('node') }

    subject{ described_node.or(another_node) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.value).to eq(node(:Or, described_node, another_node)) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} OR node)") }
  end
end
