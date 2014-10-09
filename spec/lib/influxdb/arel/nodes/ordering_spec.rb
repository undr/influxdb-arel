require 'spec_helper'

describe Influxdb::Arel::Nodes::Ordering do
  it_should_behave_like :unary_node, :Ordering, 'ORDER VALUE'

  describe '#invert' do
    subject{ node(:Ordering, direction).invert }

    context 'from ascending order' do
      let(:direction){ :asc }
      specify{ expect(subject).to eq(node(:Ordering, :desc)) }
    end

    context 'from descending order' do
      let(:direction){ :desc }
      specify{ expect(subject).to eq(node(:Ordering, :asc)) }
    end
  end
end
