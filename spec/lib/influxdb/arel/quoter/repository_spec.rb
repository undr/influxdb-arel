require 'spec_helper'

describe Influxdb::Arel::Quoter::Repository do
  subject{ Influxdb::Arel::Quoter::Repository.new }

  before{ subject.add(String){|value| "quoted #{value}" } }

  specify{ expect(subject.quote('string')).to eq('quoted string') }
  specify{ expect(subject.quote(/.*/)).to eq('/.*/') }
end
