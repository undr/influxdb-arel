shared_examples_for :node_math do |node_sql|
  describe '#+' do
    subject{ described_node + 10 }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} + 10)") }
  end

  describe '#-' do
    subject{ described_node - 10 }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} - 10)") }
  end

  describe '#/' do
    subject{ described_node / 10 }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Division) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} / 10") }
  end

  describe '#*' do
    subject{ described_node * 10 }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Multiplication) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} * 10") }
  end
end
