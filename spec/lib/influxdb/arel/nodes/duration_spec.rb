require 'spec_helper'

describe Influxdb::Arel::Nodes::Duration do
  let(:described_node){ node(:Duration, 10, 'h') }

  it_should_behave_like :node_to_sql, '10h'

  describe '#eql?' do
    specify{ expect(described_node.eql?(node(:Duration, 10, 'h'))).to be_truthy }
    specify{ expect(described_node.eql?(node(:Duration, 10, 's'))).to be_falsy }
    specify{ expect(described_node.eql?(node(:Duration, 11, 'h'))).to be_falsy }
  end

  describe 'initialization' do
    context 'with invalid suffix' do
      subject{ node(:Duration, 10, 'hours') }

      specify{ expect(subject).to eq(node(:Duration, 10, 'u')) }
    end

    context 'with nulled suffix' do
      subject{ node(:Duration, 10, nil) }

      specify{ expect(subject).to eq(node(:Duration, 10, 'u')) }
    end

    context 'with value as string' do
      subject{ node(:Duration, '10', 'h') }

      specify{ expect(subject).to eq(node(:Duration, 10, 'h')) }
    end

    context 'with value as float' do
      subject{ node(:Duration, 10.34, 'h') }

      specify{ expect(subject).to eq(node(:Duration, 10, 'h')) }
    end

    context 'with invalid value' do
      subject{ node(:Duration, 'one', 'h') }

      specify{ expect(subject).to eq(node(:Duration, 0, 'h')) }
    end

    context 'with nulled value' do
      subject{ node(:Duration, nil, 'h') }

      specify{ expect(subject).to eq(node(:Duration, 0, 'h')) }
    end
  end

  describe '#time' do
    subject{ node(:Duration, 10, 'h').time }

    specify{ expect(subject).to eq(node(:Time, node(:Duration, 10, 'h'))) }
    specify{ expect(subject.to_sql).to eq('time(10h)') }
  end

  describe '#ago' do
    subject{ node(:Duration, 10, 'h').ago }

    specify{ expect(subject).to eq(node(:Grouping, node(:Subtraction, node(:Now), node(:Duration, 10, 'h')))) }
    specify{ expect(subject.to_sql).to eq('(now() - 10h)') }
  end

  describe '#since' do
    subject{ node(:Duration, 10, 'h').since }

    specify{ expect(subject).to eq(node(:Grouping, node(:Addition, node(:Now), node(:Duration, 10, 'h')))) }
    specify{ expect(subject.to_sql).to eq('(now() + 10h)') }
  end
end
