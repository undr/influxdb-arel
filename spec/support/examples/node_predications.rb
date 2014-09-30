shared_examples_for :node_predications do |node_sql|
  describe '#not_eq' do
    subject{ described_node.not_eq(1) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::NotEqual) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(1) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} <> 1") }
  end

  describe '#not_eq_any' do
    subject{ described_node.not_eq_any([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} <> 1 OR #{node_sql} <> 2)") }
  end

  describe '#not_eq_all' do
    subject{ described_node.not_eq_all([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} <> 1 AND #{node_sql} <> 2)") }
  end

  describe '#eq' do
    subject{ described_node.eq(1) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Equality) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(1) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} = 1") }
  end

  describe '#eq_any' do
    subject{ described_node.eq_any([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} = 1 OR #{node_sql} = 2)") }
  end

  describe '#eq_all' do
    subject{ described_node.eq_all([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} = 1 AND #{node_sql} = 2)") }
  end

  describe '#matches' do
    subject{ described_node.matches(/.*/) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Matches) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(/.*/) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} =~ /.*/") }
  end

  describe '#matches_any' do
    subject{ described_node.matches_any([/\w*/, /\d*/]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} =~ /\\w*/ OR #{node_sql} =~ /\\d*/)") }
  end

  describe '#matches_all' do
    subject{ described_node.matches_all([/\w*/, /\d*/]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} =~ /\\w*/ AND #{node_sql} =~ /\\d*/)") }
  end

  describe '#does_not_match' do
    subject{ described_node.does_not_match(/.*/) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::DoesNotMatch) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(/.*/) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} !~ /.*/") }
  end

  describe '#does_not_match_any' do
    subject{ described_node.does_not_match_any([/\w*/, /\d*/]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} !~ /\\w*/ OR #{node_sql} !~ /\\d*/)") }
  end

  describe '#does_not_match_all' do
    subject{ described_node.does_not_match_all([/\w*/, /\d*/]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} !~ /\\w*/ AND #{node_sql} !~ /\\d*/)") }
  end

  describe '#gteq' do
    subject{ described_node.gteq(1) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::GreaterThanOrEqual) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(1) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} >= 1") }
  end

  describe '#gteq_any' do
    subject{ described_node.gteq_any([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} >= 1 OR #{node_sql} >= 2)") }
  end

  describe '#gteq_all' do
    subject{ described_node.gteq_all([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} >= 1 AND #{node_sql} >= 2)") }
  end

  describe '#gt' do
    subject{ described_node.gt(1) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::GreaterThan) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(1) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} > 1") }
  end

  describe '#gt_any' do
    subject{ described_node.gt_any([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} > 1 OR #{node_sql} > 2)") }
  end

  describe '#gt_all' do
    subject{ described_node.gt_all([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} > 1 AND #{node_sql} > 2)") }
  end

  describe '#lt' do
    subject{ described_node.lt(1) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::LessThan) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(1) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} < 1") }
  end

  describe '#lt_any' do
    subject{ described_node.lt_any([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} < 1 OR #{node_sql} < 2)") }
  end

  describe '#lt_all' do
    subject{ described_node.lt_all([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} < 1 AND #{node_sql} < 2)") }
  end

  describe '#lteq' do
    subject{ described_node.lteq(1) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::LessThanOrEqual) }
    specify{ expect(subject.left).to eq(described_node) }
    specify{ expect(subject.right).to eq(1) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} <= 1") }
  end

  describe '#lteq_any' do
    subject{ described_node.lteq_any([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} <= 1 OR #{node_sql} <= 2)") }
  end

  describe '#lteq_all' do
    subject{ described_node.lteq_all([1, 2]) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Grouping) }
    specify{ expect(subject.to_sql).to eq("(#{node_sql} <= 1 AND #{node_sql} <= 2)") }
  end

  describe '#in' do
    subject{ described_node.in(expr) }

    context 'with infinity range' do
      let(:expr){ -Float::INFINITY..Float::INFINITY }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::Equality) }
      specify{ expect(subject.left).to eq(1) }
      specify{ expect(subject.right).to eq(1) }
      specify{ expect(subject.to_sql).to eq("1 = 1") }
    end

    context 'with endless range' do
      let(:expr){ 1..Float::INFINITY }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::GreaterThanOrEqual) }
      specify{ expect(subject.left).to eq(described_node) }
      specify{ expect(subject.right).to eq(1) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} >= 1") }
    end

    context 'with startless range' do
      let(:expr){ -Float::INFINITY..1 }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::LessThanOrEqual) }
      specify{ expect(subject.left).to eq(described_node) }
      specify{ expect(subject.right).to eq(1) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} <= 1") }
    end

    context 'with startless range with exclided end' do
      let(:expr){ -Float::INFINITY...1 }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::LessThan) }
      specify{ expect(subject.left).to eq(described_node) }
      specify{ expect(subject.right).to eq(1) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} < 1") }
    end

    context 'with range' do
      let(:expr){ -1..1 }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::And) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} >= -1 AND #{node_sql} <= 1") }
    end

    context 'with range with exclided end' do
      let(:expr){ -1...1 }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::And) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} >= -1 AND #{node_sql} < 1") }
    end

    context 'with array' do
      subject{ described_node.in([1, 2]) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::In) }
      specify{ expect(subject.left).to eq(described_node) }
      specify{ expect(subject.right).to eq([1, 2]) }
      specify{ expect(subject.to_sql).to eq("#{node_sql} IN (1, 2)") }
    end
  end
end
