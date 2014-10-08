require 'spec_helper'

describe Influxdb::Arel::Builder do
  describe '#from' do
    subject{ builder(:events).from(:table) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.tables).to eq([node(:Table, :table)]) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM table') }
  end

  describe '#merge' do
    subject{ builder(:events).merge(:errors) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, :events), node(:Table, :errors))) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }

    context 'when table as argument' do
      subject{ builder(:events).merge(node(:Table, :errors)) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, :events), node(:Table, :errors))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end

    context 'without argument' do
      subject{ builder(:events).merge }
      specify{ expect{ subject }.to raise_error }
    end

    context 'without argument with more than two tables' do
      subject{ builder.from(:events, :errors, :logs).merge }
      specify{ expect{ subject }.to raise_error }
    end

    context 'without argument with two tables' do
      subject{ builder.from(:events, :errors).merge }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.merge).to eq(node(:Merge, node(:Table, :events), node(:Table, :errors))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events MERGE errors') }
    end
  end

  describe '#join' do
    subject{ builder(:events).join(:errors) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, :events), node(:Table, :errors))) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }

    context 'when table as argument' do
      subject{ builder(:events).join(node(:Table, :errors)) }

      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, :events), node(:Table, :errors))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }
    end

    context 'without argument' do
      subject{ builder(:events).join }
      specify{ expect{ subject }.to raise_error }
    end

    context 'without argument with more than two tables' do
      subject{ builder.from(:events, :errors, :logs).join }
      specify{ expect{ subject }.to raise_error }
    end

    context 'without argument with two tables' do
      subject{ builder.from(:events, :errors).join }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.join).to eq(node(:Join, node(:Table, :events), node(:Table, :errors))) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events INNER JOIN errors') }
    end
  end

  describe '#order' do
    context 'when sort by ascending order' do
      subject{ builder(:events).order(:asc) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'asc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by ascending order' do
      subject{ builder(:events).order('asc') }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'asc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
    end

    context 'when sort by descending order' do
      subject{ builder(:events).order(:desc) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'desc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end

    context 'when sort by descending order' do
      subject{ builder(:events).order('desc') }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.order_value).to eq(node(:Ordering, 'desc')) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
    end
  end

  describe '#asc' do
    subject{ builder(:events).asc }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.order_value).to eq(node(:Ordering, 'asc')) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER ASC') }
  end

  describe '#desc' do
    subject{ builder(:events).desc }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.order_value).to eq(node(:Ordering, 'desc')) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events ORDER DESC') }
  end

  describe '#limit' do
    subject{ builder(:events).limit(100) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.limit_value).to eq(node(:Limit, 100)) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events LIMIT 100') }
  end

  describe '#group' do
    subject{ builder(:events).group{ [time('1s'), 'name', :type] } }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.group_values).to eq([
      node(:Time, '1s'), node(:Attribute, 'name'), node(:Attribute, 'type')
    ]) }
    specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }

    context 'chaining' do
      subject{ builder(:events).group{ time('1s') }.group('name', :type) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.ast.groups).to eq([
         node(:Time, '1s'), node(:Attribute, 'name'), node(:Attribute, 'type')
      ]) }
      specify{ expect(subject.to_sql).to eq('SELECT * FROM events GROUP BY time(1s), name, type') }
    end
  end

  describe '#where' do
    subject{ builder(:events).where("name = 'Undr'") }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.where_values).to eq([sql("name = 'Undr'")]) }
    specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr'") }

    context 'chaining' do
      subject{ builder(:events).where("name = 'Undr'").where(sql("email = 'undr@gmail.com'")) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.where_values).to eq([sql("name = 'Undr'"), sql("email = 'undr@gmail.com'")]) }
      specify{ expect(subject.to_sql).to eq("SELECT * FROM events WHERE name = 'Undr' AND email = 'undr@gmail.com'") }
    end
  end

  describe '#select' do
    subject{ builder('events').select('name', :type) }
    specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
    specify{ expect(subject.select_values).to eq([node(:Attribute, 'name'), node(:Attribute, 'type')]) }
    specify{ expect(subject.to_sql).to eq('SELECT name, type FROM events') }

    context 'chaining' do
      subject{ builder('events').select{ time }.select('name', :type) }
      specify{ expect(subject).to be_instance_of(Influxdb::Arel::SelectManager) }
      specify{ expect(subject.select_values).to eq(
        [node(:Attribute, 'time'), node(:Attribute, 'name'), node(:Attribute, 'type')]
      ) }
      specify{ expect(subject.to_sql).to eq('SELECT time, name, type FROM events') }
    end
  end
end
