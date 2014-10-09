require 'spec_helper'

describe Influxdb::Arel::Nodes::Merge do
  describe 'initialization' do
    let(:described_node){ node(:Merge, left, right) }

    context 'with tables' do
      let(:left){ node(:Table, 'left') }
      let(:right){ node(:Table, 'right') }

      specify{ expect(described_node.left).to be_instance_of(Influxdb::Arel::Nodes::Table) }
      specify{ expect(described_node.right).to be_instance_of(Influxdb::Arel::Nodes::Table) }
    end

    context 'with aliases' do
      let(:left){ node(:Table, 'left').as(:alias1) }
      let(:right){ node(:Table, 'right').as(:alias2) }

      specify{ expect(described_node.left).to be_instance_of(Influxdb::Arel::Nodes::Table) }
      specify{ expect(described_node.right).to be_instance_of(Influxdb::Arel::Nodes::Table) }
    end
  end

  it_should_behave_like :binary_node, :Merge, 'left MERGE right'
end
