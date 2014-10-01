# Influxdb::Arel

Influxdb::Arel is a SQL AST manager for Influxdb dialect. It simplifies the generation of complex SQL queries.

[![Build Status](https://travis-ci.org/undr/influxdb-arel.svg?branch=master)](https://travis-ci.org/undr/influxdb-arel) [![Code Climate](https://codeclimate.com/github/undr/influxdb-arel/badges/gpa.svg)](https://codeclimate.com/github/undr/influxdb-arel) [![Gem Version](https://badge.fury.io/rb/influxdb-arel.svg)](http://badge.fury.io/rb/influxdb-arel)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'influxdb-arel'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install influxdb-arel
```

## Usage

### Introduction

At start you should create a table which you will work with:

```ruby
events = Influxdb::Arel::Table.new(:events)
events.to_sql
# => SELECT * FROM events
```

You can use both string and symbol as table name:

```ruby
Influxdb::Arel::Table.new('events') == Influxdb::Arel::Table.new(:events)
# => true
```

You will get the same result.

If you want to use convenient shortcuts, such as `10.h.ago` or `1.w.time` you should require file with core extensions

```ruby
require 'influxdb/arel/core_extensions'

1.h
# => #<Influxdb::Arel::Nodes::Duration:0x00000102143a68 @left=1, @right="h">

1.h.to_sql
# => "1h"

1.h.time
# => #<Influxdb::Arel::Nodes::Time:0x0000010282f728 @expr=#<Influxdb::Arel::Nodes::Duration:0x0000010282f868 @left=1, @right="h">>

1.h.time.to_sql
# => "time(1h)"

1.h.ago.to_sql
# => "(now() - 1h)"

1.h.since.to_sql
# => "(now() + 1h)"

'time(1s)'.to_arel == Influxdb::Arel::Nodes::SqlLiteral.new('time(1s)')
# => true

'time(1s)'.to_influxdb_arel == Influxdb::Arel::Nodes::SqlLiteral.new('time(1s)')
# => true

:events.to_arel == Influxdb::Arel::Table.new('events')
# => true

:events.to_influxdb_arel == Influxdb::Arel::Table.new('events')
# => true

'MEAN(value)'.as('mean_value')
# => #<Influxdb::Arel::Nodes::As:0x00000101218f70 @left="MEAN(value)", @right="mean_value">

'MEAN(value)'.as('mean_value').to_sql
# => "MEAN(value) AS mean_value"

:events.as('user_events')
# => #<Influxdb::Arel::Nodes::TableAlias:0x0000010180f8c0 @left=#<Influxdb::Arel::Table:0x0000010180f938 @name="events">, @right="user_events">

:events.as('user_events').to_sql
# => "events AS user_events"
```

### Setting of table names

There are several ways to set another table name to table object. You should call `from` method:

- With strings or symbols

```ruby
events.from('events', :errors).to_sql
# => SELECT * FROM events, errors
```

- With table objects

```ruby
events.from(Influxdb::Arel::Table.new(:errors)).to_sql
# => SELECT * FROM errors
```

- With sql literal objects

```ruby
events.from(Influxdb::Arel::Nodes::SqlLiteral.new('errors')).to_sql
# => SELECT * FROM errors
```

- With table aliases

*There will be only a table name without alias in result SQL because aliases are used only when joining tables*

```ruby
events.from(events.as('user_errors')).to_sql
# => SELECT * FROM errors
```

- With regexp object

```ruby
events.from(/.*/).to_sql
# => SELECT * FROM /.*/
```

### Joining tables

You can join two tables using `join` method.

It will join two first tables from tables list if method is called without argument

```ruby
table = Influxdb::Arel::Table.new('table')
table.from('table1', 'table2').join.to_sql
# => SELECT * FROM table1 INNER JOIN table2
```

It will change nothing if method is called without argument and tables list contains less than two table.

```ruby
table.join.to_sql
# => SELECT * FROM table
```

It will join first table from tables list with given table if argument exists.

```ruby
table.join('table2').to_sql
# => SELECT * FROM table INNER JOIN table2
```

```ruby
table.from('table1', 'table2').join('table3').to_sql
# => SELECT * FROM table1 INNER JOIN table3
```

Also, you can define alias for each joined table. It would be useful for self joining table.

```ruby
table.from(table.as(:table_one)).join(table.as(:table_two)).to_sql
# => SELECT * FROM table AS table_one INNER JOIN table AS table_two
```

Chaining this method will replace previous join definition.

```ruby
table1 = Influxdb::Arel::Table.new('table')
table.join(table1).join(table1.as('alias')).to_sql
# => SELECT * FROM table INNER JOIN table1 AS alias
```

### Merging tables

You can merge tables using `merge` method.

It will merge two first tables from tables list if method is called without argument.

```ruby
table = Influxdb::Arel::Table.new('table')
table.from('table1', 'table2').merge.to_sql
# => SELECT * FROM table1 MERGE table2
```

It will change nothing if method is called without argument and tables list contains less than two table.

```ruby
table.merge.to_sql
# => SELECT * FROM table
```

It will merge first table from tables list with given table if argument exists.

```ruby
table.merge('table2').to_sql
# => SELECT * FROM table MERGE table2

table.from('table1', 'table2').merge('table3').to_sql
# => SELECT * FROM table1 MERGE table3
```

Chaining this method will replace previous merge definition.

```ruby
table.megre('table1').merge('table2').to_sql
# => SELECT * FROM table MERGE table2
```

### Grouping of results

Grouping of results by specified columns or expressions, such as `time(10m)`:

```ruby
table = Influxdb::Arel::Table.new('table')
table.group(table.time(10.m), table[:host]).to_sql
# => SELECT * FROM table GROUP BY time(10m), host
```

If you want to fill intervals with no data you should call `fill` method:

```ruby
table.group(10.m.time, table[:host]).fill(0).to_sql
# => SELECT * FROM table GROUP BY time(10m), host fill(0)
```

Chaining this method will add expression to the grouping set.

```ruby
table.group(table.time(10.m)).group(:host).to_sql
# => SELECT * FROM table GROUP BY time(10m), host
```

### Ordering of results

Yo can set the ordering of results using `order` method

Possible values:

* `:asc`- Default value. Results will be sorted by ascending order.
* `'asc'`- Results will be sorted by ascending order.
* `:desc`- Results will be sorted by descending order.
* `'desc'`- Results will be sorted by descending order.

```ruby
table = Influxdb::Arel::Table.new('table')
table.order(:desc).to_sql
table.order('desc').to_sql
# => SELECT * FROM table ORDER DESC

table.order(:asc).to_sql
table.order('asc').to_sql
# => SELECT * FROM table ORDER ASC
```

As well it's possible to use `asc` and `desc` methods

```ruby
table.where(table[:time].lteq(Time.now)).asc.to_sql
# => SELECT * FROM table WHERE time <= 1412137303000000 ORDER ASC
table.where(table[:time].lteq(Time.now)).desc.to_sql
# => SELECT * FROM table WHERE time <= 1412137303000000 ORDER DESC
```

Chaining this methods will replace previous order definition.

```ruby
table.where(table[:time].lteq(Time.now)).asc.desc.to_sql
# => SELECT * FROM table WHERE time <= 1412137303000000 ORDER DESC
```

### Query conditions

You can specify conditions for selection query using `where` method

```ruby
table = Influxdb::Arel::Table.new('table')
table.where(table[:name].eq('Undr')).to_sql
# => SELECT * FROM table WHERE name = 'Undr'
```

```ruby
table.where(table[:name].eq('Undr').or(table[:name].eq('Andrei'))).to_sql
# => SELECT * FROM table WHERE name = 'Undr' OR name = 'Andrei'
```

Chaining this method will add expression to the condition set. They will join using `AND` boolean expression.

```ruby
table.where(table[:name].eq('Undr')).where(table[:time].lt(10.h.ago).to_sql
# => SELECT * FROM table WHERE name = 'Undr' AND time < (now() - 10h)
```


### SELECT clause

You can specify columns or expressions for SELECT clause using `column` method. By default, it's `*`.

```ruby
table = Influxdb::Arel::Table.new('cpu_load')
table.to_sql
# => SELECT * FROM cpu_load

table.column((table[:system] + table[:user]).as(:sum)).to_sql
# => SELECT (system + user) AS sum FROM cpu_load

table.column(
  table[:idle].mean.as(:idle_mean),
  table[:user].mean.as(:user_mean)
).group(1.d.time).to_sql
# => SELECT MEAN(idle) AS idle_mean, MEAN(user) AS user_mean FROM cpu_load GROUP BY time(1d)
```

It might be convenient to use aliases for complex expressions, such as functions or some mathematical expressions. Also the aliasing needed when joining tables. For example:

```ruby
alias1 = table.as('table1')
alias2 = table.as('table2')
table.from(alias1, alias2).
  column(alias1[:idle], alias2[:idle]).
  join.to_sql
# => SELECT table1.idle, table2.idle FROM table AS table1 INNER JOIN table AS table2
```

### Limits

You can set a limit for a result set

```ruby
table = Influxdb::Arel::Table.new('cpu_load')
table.take(100).to_sql
# => SELECT * FROM cpu_load LIMIT 100
```

## Contributing

1. Fork it ( https://github.com/undr/influxdb-arel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
