shared_examples_for :node_to_sql do |node_sql|
  describe '#to_sql' do
    specify{ expect(described_node.to_sql).to eq(node_sql) }
  end
end

shared_examples_for :node_as do |node_sql|
  describe '#as' do
    subject{ described_node.as('alias') }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Nodes::As) }
    specify{ expect(subject.to_sql).to eq("#{node_sql} AS alias") }
  end
end

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

shared_examples_for :binary_node do |klass, node_sql = nil|
  let(:described_node){ node(klass, sql('left'), sql('right')) }

  it_should_behave_like :node_to_sql, node_sql if node_sql

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(klass, sql('left'), sql('right')))).to be_truthy }
    specify{ expect(described_node.eql?(node(klass, sql('right'), sql('left')))).to be_falsy }
  end
end

shared_examples_for :unary_node do |klass, node_sql = nil|
  let(:described_node){ node(klass, sql('value')) }

  it_should_behave_like :node_to_sql, node_sql if node_sql

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(klass, sql('value')))).to be_truthy }
    specify{ expect(described_node.eql?(node(klass, sql('another value')))).to be_falsy }
  end
end

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
