require 'spec_helper'

describe Influxdb::Arel::Table do
  describe '#sql' do
    specify{ expect(table('events').sql('time(1s)')).to eq(sql('time(1s)')) }
  end

  describe '#star' do
    specify{ expect(table('events').star).to eq(sql('*')) }
  end

  describe '#alias' do
    subject{ table('events').alias('events1') }
    specify{ expect(subject).to eq(node(:TableAlias, table('events'), 'events1')) }
    specify{ expect(subject.to_sql).to eq('events AS events1') }
  end

  describe '#from' do
    subject{ table('events').from('table') }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.series).to eq([sql('table')]) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
  end

  describe '#merge' do
    subject{ table('events').merge('errors') }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), sql('errors'))) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }

    context 'when table as argument' do
      subject{ table('events').merge(table('errors')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'when alias as argument' do
      let(:table_alias){ table('errors').as('fatal_errors') }

      subject{ table('events').merge(table_alias) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'without argument' do
      subject{ table('events').merge }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to be_nil }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'without argument with many series' do
      subject{ table('events').from('user_events', 'errors').merge }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, sql('user_events'), sql('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events MERGE errors') }
    end
  end

  describe '#join' do
    subject{ table('events').join('errors') }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.join).to eq(node(:Join, table('events'), sql('errors'))) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }

    context 'when table as argument' do
      subject{ table('events').join(table('errors')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }
    end

    context 'when alias as argument' do
      let(:table_alias){ table('errors').as('fatal_errors') }

      subject{ table('events').join(table_alias) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table('events'), table_alias)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors AS fatal_errors') }
    end

    context 'without argument' do
      subject{ table('events').join }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to be_nil }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'without argument with many series' do
      subject{ table('events').from('user_events', 'errors').join }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, sql('user_events'), sql('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events INNER JOIN errors') }
    end
  end

  describe '#order' do
    context 'when sort by ascending order' do
      subject{ table('events').order(:asc) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(node(:Ordering, 'asc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ table('events').order('asc') }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(node(:Ordering, 'asc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by descending order' do
      subject{ table('events').order(:desc) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(node(:Ordering, 'desc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ table('events').order('desc') }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(node(:Ordering, 'desc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end
  end

  describe '#take' do
    subject{ table('events').take(100) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.taken).to eq(node(:Limit, 100)) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events LIMIT 100') }
  end

  describe '#group' do
    subject{ table('events').group('time(1s)', 'name', :type) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.groups).to eq([
      node(:Group, sql('time(1s)')), node(:Group, sql('name')), node(:Group, sql('type'))
    ]) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }

    context 'chaining' do
      subject{ table('events').group('time(1s)').group('name', :type) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.groups).to eq([
        node(:Group, sql('time(1s)')), node(:Group, sql('name')), node(:Group, sql('type'))
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end
  end

  describe '#where' do
    subject{ table('events').where(sql("name = 'Undr'")) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.wheres).to eq([sql("name = 'Undr'")]) }
    specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }

    context 'chaining' do
      subject{ table('events').where(sql("name = 'Undr'")).where(sql("email = 'undr@gmail.com'")) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.wheres).to eq([sql("name = 'Undr'"), sql("email = 'undr@gmail.com'")]) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr' AND email = 'undr@gmail.com'") }
    end
  end

  describe '#column' do
    subject{ table('events').column(table('events')[:time], 'name', :type) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.columns).to eq([table('events')[:time], sql('name'), sql('type')]) }
    specify{ expect(subject.to_sql).to eq('SELECT time, name, type FROM events') }

    context 'chaining' do
      subject{ table('events').column(table('events')[:time]).column('name', :type) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.columns).to eq([table('events')[:time], sql('name'), sql('type')]) }
      specify{ expect(subject.to_sql).to eq('SELECT time, name, type FROM events') }
    end
  end

  describe '#table_alias' do
    specify{ expect(table('events').table_alias).to be_nil }
  end

  describe '#unalias' do
    specify{ expect(table('events').unalias).to eq(table('events')) }
  end
end
