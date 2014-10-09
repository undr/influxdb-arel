shared_examples_for :node_joining_merging do |node_sql|
  describe '#join' do
    context 'with string' do
      subject{ described_node.join('table') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Join) }
      specify{ expect(subject.right).to eq(node(:Table, 'table')) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} INNER JOIN table") }
    end

    context 'with symbol' do
      subject{ described_node.join(:table) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Join) }
      specify{ expect(subject.right).to eq(node(:Table, 'table')) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} INNER JOIN table") }
    end

    context 'with node' do
      subject{ described_node.join(node(:Table, 'table')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Join) }
      specify{ expect(subject.right).to eq(node(:Table, 'table')) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} INNER JOIN table") }
    end
  end

  describe '#merge' do
    context 'with string' do
      subject{ described_node.merge('table') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Merge) }
      specify{ expect(subject.right).to eq(node(:Table, 'table')) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} MERGE table") }
    end

    context 'with symbol' do
      subject{ described_node.merge(:table) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Merge) }
      specify{ expect(subject.right).to eq(node(:Table, 'table')) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} MERGE table") }
    end

    context 'with node' do
      subject{ described_node.merge(node(:Table, 'table')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Merge) }
      specify{ expect(subject.right).to eq(node(:Table, 'table')) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} MERGE table") }
    end
  end
end
