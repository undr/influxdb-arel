require 'spec_helper'

describe Influxdb::Arel::SelectManager do
  let(:manager){ Influxdb::Arel::SelectManager.new(:events) }

  describe '#group' do
    context 'without block' do
      subject{ manager.group('time(1s)', 'name', :type) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.group_values).to eq([
        node(:Attribute, 'time(1s)'), node(:Attribute, 'name'), node(:Attribute, 'type')
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end

    context 'with block' do
      subject{ manager.group{ [time('1s'), name, :type] } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.group_values).to eq([
        node(:Time, '1s'), node(:Attribute, 'name'), node(:Attribute, 'type')
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end

    context 'chaining' do
      subject{ manager.group('time(1s)').group('name', :type) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.group_values).to eq([
        node(:Attribute, 'time(1s)'), node(:Attribute, 'name'), node(:Attribute, 'type')
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end
  end

  describe '#group!' do
    context 'without block' do
      subject{ manager.group!('time(1s)', 'name', :type) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.group_values).to eq([
        node(:Attribute, 'time(1s)'), node(:Attribute, 'name'), node(:Attribute, 'type')
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end

    context 'with block' do
      subject{ manager.group!{ [time('1s'), name, :type] } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.group_values).to eq([
        node(:Time, '1s'), node(:Attribute, 'name'), node(:Attribute, 'type')
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end

    context 'chaining' do
      subject{ manager.group('time(1s)').group!('name', :type) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.group_values).to eq([node(:Attribute, 'name'), node(:Attribute, 'type')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY name, type') }
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
    context 'with symbol' do
      subject{ manager.from(:table) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with string' do
      subject{ manager.from('table') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with block' do
      subject{ manager.from{ table } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'table')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
    end

    context 'with regexp' do
      subject{ manager.from(/events\..*/) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to be_nil }
      specify{ expect(subject.ast.regexp).to eq(node(:Table, /events\..*/)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM /events\..*/') }
    end

    context 'with several regexps' do
      subject{ manager.from(/events\..*/, /logs\..*/) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to be_nil }
      specify{ expect(subject.ast.regexp).to eq(node(:Table, /events\..*/)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM /events\..*/') }
    end

    context 'with nil' do
      subject{ manager.from(nil) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'events')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events') }
    end

    context 'with several tables' do
      subject{ manager.from(:table1){ [table2, :table3] } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'table1'), node(:Table, 'table2'), node(:Table, 'table3')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table1, table2, table3') }
    end

    context 'with several non unique tables' do
      subject{ manager.from(:table1){ [table1, :table1] } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'table1')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table1') }
    end

    context 'chaining' do
      subject{ manager.from(:table1).from(:table2) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.tables).to eq([node(:Table, 'table2')]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM table2') }
    end

    context 'joining' do
      let(:alias1){ node(:Table, 'table1').as(:alias1) }
      let(:alias2){ node(:Table, 'table2').as(:alias2) }

      context do
        subject{ manager.from{ join(:table1, :table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 INNER JOIN table2') }
      end

      context do
        subject{ manager.from{ join(table1, table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 INNER JOIN table2') }
      end

      context do
        subject{ manager.from{ join(table1.as(:alias1), table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, alias1, alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 AS alias1 INNER JOIN table2 AS alias2') }
      end

      context do
        subject{ manager.from(:table1){ join(:table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 INNER JOIN table2') }
      end

      context do
        subject{ manager.from(:table1){ join(table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 INNER JOIN table2') }
      end

      context do
        subject{ manager.from(:table1){ join(table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'table1'), alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 INNER JOIN table2 AS alias2') }
      end

      context do
        subject{ manager.from{ table1.join(table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'table1'), alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 INNER JOIN table2 AS alias2') }
      end

      context do
        subject{ manager.from{ table1.as(:alias1).join(table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, alias1, alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 AS alias1 INNER JOIN table2 AS alias2') }
      end
    end

    context 'merging' do
      let(:alias1){ node(:Table, 'table1').as(:alias1) }
      let(:alias2){ node(:Table, 'table2').as(:alias2) }

      context do
        subject{ manager.from{ merge(:table1, :table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from{ merge(table1, table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from{ merge(table1.as(:alias1), table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, alias1, alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from(:table1){ merge(:table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from(:table1){ merge(table2) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'table1'), node(:Table, 'table2'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from(:table1){ merge(table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'table1'), alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from{ table1.merge(table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'table1'), alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end

      context do
        subject{ manager.from{ table1.as(:alias1).merge(table2.as(:alias2)) } }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, alias1, alias2)) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM table1 MERGE table2') }
      end
    end
  end

  describe '#join' do
    context 'with one table' do
      subject{ manager.join(:errors) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'events'), node(:Table, 'errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }
    end

    context 'with two table' do
      context do
        let(:manager){ Influxdb::Arel::SelectManager.new }

        subject{ manager.join(:errors, :logs) }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'errors'), node(:Table, 'logs'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM errors INNER JOIN logs') }
      end

      context 'and default table' do
        subject{ manager.join(:errors, :logs) }

        specify{ expect{ subject }.to raise_error }
      end
    end

    context 'without argument' do
      subject{ manager.join }
      specify{ expect{ subject }.to raise_error }
    end

    context 'without argument but with many series' do
      subject{ manager.from(:user_events, :errors).join }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'user_events'), node(:Table, 'errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events INNER JOIN errors') }
    end

    context 'without argument but with too many aliases' do
      subject{ manager.from(:table1, :table2, :table3).join }
      specify{ expect{ subject }.to raise_error }
    end

    context 'with merging' do
      subject{ manager.from(:user_events, :errors).merge.join }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'user_events'), node(:Table, 'errors'))) }
      specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'user_events'), node(:Table, 'errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events INNER JOIN errors') }
    end
  end

  describe '#merge' do
    context 'with one table' do
      subject{ manager.merge(:errors) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'events'), node(:Table, 'errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'with two table' do
      context do
        let(:manager){ Influxdb::Arel::SelectManager.new }

        subject{ manager.merge(:errors, :logs) }

        specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
        specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'errors'), node(:Table, 'logs'))) }
        specify{ expect(subject.to_sql).to eq('SELECT * FROM errors MERGE logs') }
      end

      context 'and default table' do
        subject{ manager.merge(:errors, :logs) }

        specify{ expect{ subject }.to raise_error }
      end
    end

    context 'without argument' do
      subject{ manager.merge }
      specify{ expect{ subject }.to raise_error }
    end

    context 'without argument but with many tables' do
      subject{ manager.from(:user_events, :errors).merge }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'user_events'), node(:Table, 'errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events MERGE errors') }
    end

    context 'without argument but with too many tables' do
      subject{ manager.from(:table1, :table2, :table3).merge }
      specify{ expect{ subject }.to raise_error }
    end

    context 'with joining' do
      subject{ manager.from(:user_events, :errors).join.merge }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, 'user_events'), node(:Table, 'errors'))) }
      specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, 'user_events'), node(:Table, 'errors'))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM user_events INNER JOIN errors') }
    end
  end

  describe '#select' do
    let(:nodes){ [node(:Attribute, 'time'), node(:Attribute, 'name'), node(:Attribute, 'age')] }

    subject{ manager.select(:time){ [name, :age] } }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.select_values).to eq(nodes) }
    specify{ expect(subject.to_sql).to eq('SELECT time, name, age FROM events') }

    context 'chaining' do
      subject{ manager.select(:time).select{ [name, :age] } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.select_values).to eq(nodes) }
      specify{ expect(subject.to_sql).to eq('SELECT time, name, age FROM events') }
    end
  end

  describe '#select!' do
    let(:nodes){ [node(:Attribute, 'time'), node(:Attribute, 'name'), node(:Attribute, 'age')] }

    subject{ manager.select!(:time){ [name, :age] } }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.select_values).to eq(nodes) }
    specify{ expect(subject.to_sql).to eq('SELECT time, name, age FROM events') }

    context 'chaining' do
      subject{ manager.select(:time).select!{ [name, :age] } }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.select_values).to eq([node(:Attribute, 'name'), node(:Attribute, 'age')]) }
      specify{ expect(subject.to_sql).to eq('SELECT name, age FROM events') }
    end
  end

  describe '#order' do
    let(:asc){ node(:Ordering, 'asc') }
    let(:desc){ node(:Ordering, 'desc') }

    context 'when sort by ascending order' do
      subject{ manager.order(:asc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ manager.order('asc') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ manager.order(asc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by descending order' do
      subject{ manager.order(:desc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ manager.order('desc') }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ manager.order(desc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(desc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    describe 'chaining' do
      subject{ manager.order(desc).order(asc) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(asc) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end
  end

  describe '#asc' do
    subject{ manager.asc }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.order_value).to eq(node(:Ordering, 'asc')) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
  end

  describe '#desc' do
    subject{ manager.desc }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.order_value).to eq(node(:Ordering, 'desc')) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
  end

  describe '#invert_order' do
    context 'from native order' do
      subject{ manager.invert_order }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'asc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'from asc to desc' do
      subject{ manager.asc.invert_order }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'desc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'from desc to asc' do
      subject{ manager.desc.invert_order }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'asc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end
  end

  describe '#limit' do
    subject{ manager.limit(100) }

    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.limit_value).to eq(node(:Limit, 100)) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events LIMIT 100') }

    context 'chaining' do
      subject{ manager.limit(100).limit(1) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.limit_value).to eq(node(:Limit, 1)) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events LIMIT 1') }
    end
  end

  # describe '#where' do
  #   context 'with conditions as string' do
  #     subject{ manager.where("name = 'Undr'") }

  #     specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
  #     specify{ expect(subject.wheres).to eq([sql("name = 'Undr'")]) }
  #     specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }
  #   end

  #   context 'with conditions as sql leteral' do
  #     subject{ manager.where(sql("name = 'Undr'")) }

  #     specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
  #     specify{ expect(subject.wheres).to eq([sql("name = 'Undr'")]) }
  #     specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }
  #   end

  #   context 'with conditions as sql node' do
  #     subject{ manager.where(table('events')[:name].eq('Undr')) }

  #     specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
  #     specify{ expect(subject.wheres).to eq([node(:Equality, table('events')[:name], 'Undr')]) }
  #     specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }
  #   end

  #   context 'chaining' do
  #     subject{ manager.where("name = 'Undr'").where("email = 'undr@gmail.com'") }

  #     specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
  #     specify{ expect(subject.wheres).to eq([sql("name = 'Undr'"), sql("email = 'undr@gmail.com'")]) }
  #     specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr' AND email = 'undr@gmail.com'") }
  #   end
  # end

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
