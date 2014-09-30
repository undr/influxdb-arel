require 'spec_helper'

describe Influxdb::Arel do
  describe '.sql' do
    specify{ expect(subject.sql('time(1s)')).to eq(sql('time(1s)')) }
  end

  describe '.star' do
    specify{ expect(subject.star).to eq(sql('*')) }
  end
end
