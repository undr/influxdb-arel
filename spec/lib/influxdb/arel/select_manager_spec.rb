require 'spec_helper'

describe Influxdb::Arel::SelectManager do
  let(:manager){ Influxdb::Arel::SelectManager.new(table('events')) }

  describe '#group' do
    subject{ manager.group('time(1s)', 'name', :type) }

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

  describe '#fill' do
    context 'with empty groups' do
      subject{ manager.fill(0) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.fill).to eq(node(:Fill, 0)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'filling empty values with integer' do
      subject{ manager.group('time(1s)').fill(0) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.fill).to eq(node(:Fill, 0)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s) fill(0)') }
    end

    context 'filling empty values with string' do
      subject{ manager.group('time(1s)').fill('empty') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.fill).to eq(node(:Fill, 'empty')) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events GROUP BY time(1s) fill('empty')") }
    end

    context 'filling empty values with sql node' do
      subject{ manager.group('time(1s)').fill(sql('name')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.fill).to eq(node(:Fill, sql('name'))) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events GROUP BY time(1s) fill(name)") }
    end
  end

  describe '#from' do
    context 'with table' do
      subject{ manager.from(table('table')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([table('table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with symbol' do
      subject{ manager.from(:table) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with string' do
      subject{ manager.from('table') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with sql node' do
      subject{ manager.from(sql('table')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with table alias' do
      subject{ manager.from(table('table').as('alias')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([table('table').as('alias')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with regexp' do
      subject{ manager.from(/events\..*/) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('/events\..*/')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM /events\..*/') }
    end

    context 'with nil' do
      subject{ manager.from(nil) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([table('events')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'with several tables' do
      subject{ manager.from('table1', table('table2'), table('table2').as('alias')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('table1'), table('table2'), table('table2').as('alias')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table1, table2') }
    end

    context 'with several non unique tables' do
      subject{ manager.from('table1', table('table1'), 'table1') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('table1'), table('table1'), sql('table1')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table1') }
    end

    context 'chaining' do
      subject{ manager.from('table1').from('table2') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.series).to eq([sql('table2')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table2') }
    end
  end

  describe '#join' do
    let(:table_alias1){ table('events').as('events1') }
    let(:table_alias2){ table('events').as('events2') }

    subject{ manager.join('errors') }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.join).to eq(node(:Join, table('events'), sql('errors'))) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }

    context 'when table as argument' do
      subject{ manager.join(table('errors')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }
    end

    context 'when alias as argument' do
      let(:table_alias){ table('errors').as('fatal_errors') }

      subject{ manager.join(table_alias) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table('events'), table_alias)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors AS fatal_errors') }
    end

    context 'with two aliases' do
      subject{ manager.from(table_alias1).join(table_alias2) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table_alias1, table_alias2)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events AS events1 INNER JOIN events AS events2') }
    end

    context 'without argument' do
      subject{ manager.join }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to be_nil }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'without argument with many series' do
      subject{ manager.from('user_events', 'errors').join }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, sql('user_events'), sql('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events INNER JOIN errors') }
    end

    context 'without argument with many aliases' do
      subject{ manager.from(table_alias1, table_alias2).join }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table_alias1, table_alias2)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events AS events1 INNER JOIN events AS events2') }
    end

    context 'with merging' do
      subject{ manager.from(table_alias1, table_alias2).merge.join }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('events'))) }
      specify{ expect(subject.ast.join).to eq(node(:Join, table_alias1, table_alias2)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events AS events1 INNER JOIN events AS events2') }
    end
  end

  describe '#merge' do
    let(:table_alias1){ table('events').as('events1') }
    let(:table_alias2){ table('errors').as('errors1') }

    subject{ manager.merge('errors') }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), sql('errors'))) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }

    context 'when table as argument' do
      subject{ manager.merge(table('errors')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'when alias as argument' do
      let(:table_alias){ table('errors').as('fatal_errors') }

      subject{ manager.merge(table_alias) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'when alias as argument' do
      let(:table_alias){ table('errors').as('fatal_errors') }

      subject{ manager.merge(table_alias) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'with two aliases' do
      subject{ manager.from(table_alias1).merge(table_alias2) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, table('events'), table('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'without argument' do
      subject{ manager.merge }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to be_nil }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'without argument with many series' do
      subject{ manager.from('user_events', 'errors').merge }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, sql('user_events'), sql('errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events MERGE errors') }
    end
  end

  describe '#column' do
    subject{ manager.column(table('events')[:time], 'name', :type) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.columns).to eq([table('events')[:time], sql('name'), sql('type')]) }
    specify{ expect(subject.to_sql).to eq('SELECT time, name, type FROM events') }

    context 'chaining' do
      subject{ manager.column(table('events')[:time]).column('name', :type) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.columns).to eq([table('events')[:time], sql('name'), sql('type')]) }
      specify{ expect(subject.to_sql).to eq('SELECT time, name, type FROM events') }
    end
  end

  describe '#order' do
    let(:asc){ node(:Ordering, 'asc') }
    let(:desc){ node(:Ordering, 'desc') }

    context 'when sort by ascending order' do
      subject{ manager.order(:asc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ manager.order('asc') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ manager.order(asc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ manager.asc }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by descending order' do
      subject{ manager.order(:desc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ manager.order('desc') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ manager.order(desc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ manager.desc }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    describe 'chaining' do
      subject{ manager.order(desc).order(asc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ordering).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end
  end

  describe '#take' do
    subject{ manager.take(100) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.taken).to eq(node(:Limit, 100)) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events LIMIT 100') }

    context 'chaining' do
      subject{ manager.take(100).take(1) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.taken).to eq(node(:Limit, 1)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events LIMIT 1') }
    end
  end

  describe '#where' do
    context 'with conditions as string' do
      subject{ manager.where("name = 'Undr'") }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.wheres).to eq([sql("name = 'Undr'")]) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }
    end

    context 'with conditions as sql leteral' do
      subject{ manager.where(sql("name = 'Undr'")) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.wheres).to eq([sql("name = 'Undr'")]) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }
    end

    context 'with conditions as sql node' do
      subject{ manager.where(table('events')[:name].eq('Undr')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.wheres).to eq([node(:Equality, table('events')[:name], 'Undr')]) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }
    end

    context 'chaining' do
      subject{ manager.where("name = 'Undr'").where("email = 'undr@gmail.com'") }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.wheres).to eq([sql("name = 'Undr'"), sql("email = 'undr@gmail.com'")]) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr' AND email = 'undr@gmail.com'") }
    end
  end

  describe '#into' do
    context 'with string as argument' do
      subject{ manager.into('events.all') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.into).to eq(node(:Into, sql('events.all'))) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events INTO events.all") }
    end

    context 'with symbol as argument' do
      subject{ manager.into(:'events.all') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.into).to eq(node(:Into, sql('events.all'))) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events INTO events.all") }
    end

    context 'with sql node as argument' do
      subject{ manager.into(sql('events.all')) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.into).to eq(node(:Into, sql('events.all'))) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events INTO events.all") }
    end

    context 'fanout placeholder' do
      subject{ manager.into('events.[host]') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.into).to eq(node(:Into, sql('events.[host]'))) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events INTO events.[host]") }
    end

    context 'many series placeholder' do
      subject{ manager.into('events.:series_name') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.into).to eq(node(:Into, sql('events.:series_name'))) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events INTO events.:series_name") }
    end
  end
end
