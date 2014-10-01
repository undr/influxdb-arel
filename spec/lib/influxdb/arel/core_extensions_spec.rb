require 'spec_helper'
require './lib/influxdb/arel/core_extensions'

describe Integer do
  describe '#u' do
    specify{ expect(1.u).to eq(node(:Duration, 1, sql('u'))) }
  end

  describe '#s' do
    specify{ expect(1.s).to eq(node(:Duration, 1, sql('s'))) }
  end

  describe '#m' do
    specify{ expect(1.m).to eq(node(:Duration, 1, sql('m'))) }
  end

  describe '#h' do
    specify{ expect(1.h).to eq(node(:Duration, 1, sql('h'))) }
  end

  describe '#d' do
    specify{ expect(1.d).to eq(node(:Duration, 1, sql('d'))) }
  end

  describe '#w' do
    specify{ expect(1.w).to eq(node(:Duration, 1, sql('w'))) }
  end
end


describe String do
  describe '#as' do
    specify{ expect('MEAN(value)'.as('mean')).to eq(node(:As, sql('MEAN(value)'), 'mean')) }
  end

  describe '#to_arel' do
    specify{ expect('events'.to_arel).to eq(sql('events')) }
  end
end

describe Symbol do
  describe '#as' do
    specify{ expect(:events.as('alias')).to eq(node(:TableAlias, table(:events), 'alias')) }
  end

  describe '#to_arel' do
    specify{ expect(:events.to_arel).to eq(table(:events)) }
  end
end
