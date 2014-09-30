require 'spec_helper'

describe Influxdb::Arel::Nodes::And do
  describe '#to_sql' do
    subject{ node(:And, ['first', sql('second'), 'third']).to_sql }

    specify{ expect(subject).to eq("'first' AND second AND 'third'") }
  end

  describe '#eql?' do
    subject{ node(:And, ['first', sql('second'), 'third']) }

    specify{ expect(subject.eql?(node(:And, ['first', sql('second'), 'third']))).to be_truthy }
    specify{ expect(subject.eql?(node(:And, ['first', 'second', 'third']))).to be_truthy }
    specify{ expect(subject.eql?(node(:And, ['first', 'second', 'third', 'fourth']))).to be_falsy }
  end
end
