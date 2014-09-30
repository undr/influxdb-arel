shared_examples_for :node_as do |node_sql|
  describe '#as' do
    subject{ described_node.as('alias') }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::As) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} AS alias") }
  end
end
