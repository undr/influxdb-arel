require 'spec_helper'

describe Influxdb::Arel::Nodes::TableAlias do
  let(:described_node){ node(:TableAlias, table('events'), 'alias') }

  subject{ described_node }

  it_should_behave_like :binary_node, :TableAlias, 'left AS right'

  describe '#relation' do
    specify{ expect(subject.relation).to eq(table('events')) }
  end

  describe '#table_alias' do
    specify{ expect(subject.table_alias).to eq('alias') }
  end

  describe '#name' do
    specify{ expect(subject.name).to eq('alias') }
  end

  describe '#[]' do
    subject{ described_node[:name] }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::Attribute) }
    specify{ expect(visitor.accept(subject)).to eq('alias.name') }
  end

  describe '#unalias' do
    specify{ expect(subject.unalias).to eq(table('events')) }
  end

  describe '#table_name' do
    specify{ expect(subject.table_name).to eq('events') }
  end
end
