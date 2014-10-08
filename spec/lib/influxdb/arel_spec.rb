require 'spec_helper'

describe Influxdb::Arel do
  describe '.sql' do
    specify{ expect(subject.sql('time(1s)')).to eq(sql('time(1s)')) }
  end

  describe '.star' do
    specify{ expect(subject.star).to eq(sql('*')) }
  end

  describe '.arelize' do
    let(:array){ ['string', :symbol, node(:Now)] }

    context 'without block' do
      specify{ expect(subject.arelize('string')).to eq(sql('string')) }
      specify{ expect(subject.arelize(:symbol)).to eq(sql(:symbol)) }
      specify{ expect(subject.arelize(node(:Now))).to eq(node(:Now)) }
      specify{ expect(subject.arelize(array)).to eq([sql('string'), sql(:symbol), node(:Now)]) }
    end

    context 'with block' do
      let(:block){ ->(e){ node(:Table, e) } }

      specify{ expect(subject.arelize('string', &block)).to eq(node(:Table, 'string')) }
      specify{ expect(subject.arelize(:symbol, &block)).to eq(node(:Table, :symbol)) }
      specify{ expect(subject.arelize(node(:Now), &block)).to eq(node(:Now)) }
      specify{
        expect(subject.arelize(array, &block)).to eq([node(:Table, 'string'), node(:Table, :symbol), node(:Now)])
      }
    end
  end
end
