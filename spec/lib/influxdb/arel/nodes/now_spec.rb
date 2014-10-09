require 'spec_helper'

describe Influxdb::Arel::Nodes::Now do
  let(:described_node){ node(:Now) }

  it_should_behave_like :node_to_sql, 'now()'
  it_should_behave_like :node_boolean_predications, 'now()'
  it_should_behave_like :node_math, 'now()'
end
