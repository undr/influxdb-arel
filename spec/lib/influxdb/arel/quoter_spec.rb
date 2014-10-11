require 'spec_helper'

describe Influxdb::Arel::Quoter do
  describe '#quote' do
    context 'with String' do
      specify{ expect(subject.quote('string')).to eq("'string'") }
    end

    context 'with Time' do
      specify{ expect(subject.quote(Time.parse('2014-10-09 10:49:19 +0700'))).to eq("'2014-10-09 03:49:19'") }
    end

    context 'with Date' do
      specify{ expect(subject.quote(Date.parse('2014-10-09'))).to eq("'2014-10-08'") }
    end

    context 'with DateTime' do
      specify{ expect(subject.quote(DateTime.parse('2014-10-09 10:49:19 +0700'))).to eq("'2014-10-09 03:49:19'") }
    end

    context 'with BigDecimal' do
      specify{ expect(subject.quote(BigDecimal.new('1.03'))).to eq('1.03') }
    end

    context 'with NilClass' do
      specify{ expect(subject.quote(nil)).to eq('null') }
    end

    context 'with SqlLiteral' do
      specify{ expect(subject.quote(sql('SOME SQL'))).to eq('SOME SQL') }
    end
  end
end
