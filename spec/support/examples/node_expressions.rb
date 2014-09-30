shared_examples_for :node_expressions do |node_sql|
  describe '#count' do
    subject{ described_node.count }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Count) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("COUNT(#{node_sql})") }
  end

  describe '#sun' do
    subject{ described_node.sum }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Sum) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("SUM(#{node_sql})") }
  end

  describe '#max' do
    subject{ described_node.max }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Max) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("MAX(#{node_sql})") }
  end

  describe '#min' do
    subject{ described_node.min }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Min) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("MIN(#{node_sql})") }
  end

  describe '#mean' do
    subject{ described_node.mean }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Mean) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("MEAN(#{node_sql})") }
  end

  describe '#mode' do
    subject{ described_node.mode }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Mode) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("MODE(#{node_sql})") }
  end

  describe '#median' do
    subject{ described_node.median }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Median) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("MEDIAN(#{node_sql})") }
  end

  describe '#mode' do
    subject{ described_node.mode }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Mode) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("MODE(#{node_sql})") }
  end

  describe '#distinct' do
    subject{ described_node.distinct }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Distinct) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("DISTINCT(#{node_sql})") }
  end

  describe '#percentile' do
    subject{ described_node.percentile(95) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Percentile) }
    specify{ expect(subject.expressions).to eq([described_node, 95]) }
    specify{ expect(subject.to_sql).to eq("PERCENTILE(#{node_sql}, 95)") }
  end

  describe '#histogram' do
    subject{ described_node.histogram(2) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Histogram) }
    specify{ expect(subject.expressions).to eq([described_node, 2]) }
    specify{ expect(subject.to_sql).to eq("HISTOGRAM(#{node_sql}, 2)") }
  end

  describe '#derivative' do
    subject{ described_node.derivative }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Derivative) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("DERIVATIVE(#{node_sql})") }
  end

  describe '#stddev' do
    subject{ described_node.stddev }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Stddev) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("STDDEV(#{node_sql})") }
  end

  describe '#first' do
    subject{ described_node.first }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::First) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("FIRST(#{node_sql})") }
  end

  describe '#last' do
    subject{ described_node.last }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Last) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("LAST(#{node_sql})") }
  end

  describe '#difference' do
    subject{ described_node.difference }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Difference) }
    specify{ expect(subject.expressions).to eq([described_node]) }
    specify{ expect(subject.to_sql).to eq("DIFFERENCE(#{node_sql})") }
  end

  describe '#top' do
    subject{ described_node.top(10) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Top) }
    specify{ expect(subject.expressions).to eq([described_node, 10]) }
    specify{ expect(subject.to_sql).to eq("TOP(#{node_sql}, 10)") }
  end

  describe '#bottom' do
    subject{ described_node.bottom(10) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Bottom) }
    specify{ expect(subject.expressions).to eq([described_node, 10]) }
    specify{ expect(subject.to_sql).to eq("BOTTOM(#{node_sql}, 10)") }
  end
end
