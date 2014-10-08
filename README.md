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

At start you should create a builder:

```ruby
builder = Influxdb::Arel::Builder.new(:events)
builder.to_sql
# => SELECT * FROM events
```

You can set default table name for the builder. Possible to use both strings and symbols:

```ruby
Influxdb::Arel::Builder.new('events') == Influxdb::Arel::Builder.new(:events)
# => true
```

If you want to use convenient shortcuts, such as `10.h.ago` or `1.w` you should require a file with core extensions

```ruby
require 'influxdb/arel/core_extensions'

1.h
# => #<Influxdb::Arel::Nodes::Duration:0x00000102143a68 @left=1, @right="h">

1.h.to_sql
# => "1h"

1.h.ago.to_sql
# => "(now() - 1h)"

1.h.since.to_sql
# => "(now() + 1h)"
```

A builder has methods for SQL construction.

* Specifying which attributes should be used in the query: `select`.

* Specifying which tables and how they should be used in the query: `from`, `merge` and `join`.

* Conditions of query: `where`.

* Grouping methods: `group` and `fill`.

* Ordering methods: `order`, `asc`, `desc` and `invert_order`.

* Specifying limitations of result set: `limit`.

* The part of continuous queries: `into`.

Most of them accept a block for building part of SQL. Inside a block calling of method will be interpreted depending on current context.
For example:

#### In `SELECT`, `WHERE`and `GROUP` contexts:

- All undefined methods will be interpreted as attributes:

```ruby
builder.where{ pp name.is_a?(Influxdb::Arel::Nodes::Attribute) }
# true
# => ...
builder.where{ name =~ /undr/ }.to_sql
# => SELECT * FROM table WHERE name =~ /undr/
```

- Method `a` returns attribute node.

```ruby
builder.where{ pp a(:name) == name }
# true
# => ...
```

- Method `time` returns `Influxdb::Arel::Nodes::Time` object. (It will be available only in `GROUP` context)

- Method `now` returns `Influxdb::Arel::Nodes::Now` object. (It will be available only in `WHERE` context)
-

#### In `FROM`, `JOIN` and `MERGE` contexts

- All undefined methods will be interpreted as tables:

```ruby
builder.select{ pp events.is_a?(Influxdb::Arel::Nodes::Table) }
# true
# => ...
builder.from{ events }.to_sql
# => SELECT * FROM events
```

- Method `t` returns table node.

```ruby
builder.from{ pp t(:table) == table }
# true
# => ...
```

- Method `join` used for joining tables (available only in `JOIN` context).

```ruby
builder.from{ join(table.as(:alias1), table.as(:alias2)) }.to_sql
# => SELECT * FROM table AS alias1 INNER JOIN table AS alias2
```

- Method `merge` used for merging tables (available only in `JOIN` context).

```ruby
builder.from{ merge(table1, table2) }.to_sql
# => SELECT * FROM table1 MERGE table2
```

Also, into the block will be available `o` method. It used for access to outer scope. For example:

```ruby
regexp = /events\..*/
builder.from{ o{ regexp } }.to_sql
# => SELECT * FROM /events\..*/
```

### `SELECT` clause

You can specify attributes or expressions for `SELECT` clause using `select` method.

```ruby
builder = Influxdb::Arel::Builder.new(:cpu_load)
builder.to_sql
# => SELECT * FROM cpu_load

builder.select{ (system + user).as(:sum) }.to_sql
# => SELECT (system + user) AS sum FROM cpu_load

builder.select{
  [mean(idle).as(:idle_mean), mean(user).as(:user_mean)]
}.group{ time(1.d) }.to_sql
# => SELECT MEAN(idle) AS idle_mean, MEAN(user) AS user_mean FROM cpu_load GROUP BY time(1d)
```

It might be convenient to use aliases for complex expressions, such as functions or some mathematical expressions.

Chaining `select` method will add attributes or expressions to the set. If you want to override expressions when use `select!` method.

```ruby
builder.select(:name).select(:age).to_sql
# => SELECT name, age FROM table
builder.select(:name).select!(:age).to_sql
# => SELECT age FROM table
```

### `FROM` clause

You can specify tables for query using `from` method.

Possible to call method:

- With strings or symbols as arguments

```ruby
builder.from('events', :errors).to_sql
# => SELECT * FROM events, errors
```

- With block

```ruby
builder.from{ errors }.to_sql
# => SELECT * FROM errors

builder.from{ [errors, :events] }.to_sql
# => SELECT * FROM errors, events
```

- You can mix both

```ruby
builder.from(:events){ errors }.to_sql
# => SELECT * FROM events, errors
```

- With regexp object

```ruby
builder.from(/.*/).to_sql
# => SELECT * FROM /.*/
```

**Warning:** *You can call method with more then one regexp but only first will be used as table name*

```ruby
builder.from(/.*/, /logs\..*/).to_sql
# => SELECT * FROM /.*/
```

Chaining this method will replace previous `FORM` definition.

```ruby
builder.from(:table1).from{ table2 }.to_sql
# => SELECT * FROM table2
```

### Joining tables

You can join two tables using `join` method.

It will join two first tables from tables list if method is called without argument

```ruby
builder = Influxdb::Arel::Builder.new(:table)
builder.from(:table1, :table2).join.to_sql
# => SELECT * FROM table1 INNER JOIN table2
builder.from{ [table1.as(:alias1), table2.as(:alias2)] }.join.to_sql
# => SELECT * FROM table1 AS alias1 INNER JOIN table2 AS alias2
```

It will raise error if method is called without argument and tables list contains less than two table.

```ruby
builder.join.to_sql
# => IllegalSQLConstruct: Ambiguous joining clause
```

It will join first table from tables list with given table if argument exists.

```ruby
builder.join(:table2).to_sql
# => SELECT * FROM table INNER JOIN table2
```

And it will raise error if number of tables is more than two.

```ruby
builder.from(:table1, :table2).join(:table3).to_sql
# => IllegalSQLConstruct: Ambiguous joining clause
```

Also, you can define alias for each joined table. It would be useful for self joining table.

```ruby
builder.from{ table.as(:table_one).join(table.as(:table_two)) }.to_sql
# => SELECT * FROM table AS table_one INNER JOIN table AS table_two
```

Chaining this method will replace previous join definition.

```ruby
builder.join(:table1).join{ table1.as(:alias) }.to_sql
# => SELECT * FROM table INNER JOIN table1 AS alias
```

### Merging tables

You can merge two tables using `merge` method.

It will merge two first tables from tables list if method is called without argument

```ruby
builder = Influxdb::Arel::Builder.new(:table)
builder.from(:table1, :table2).merge.to_sql
# => SELECT * FROM table1 MERGE table2
builder.from{ [table1.as(:alias1), table2.as(:alias2)] }.merge.to_sql
# => SELECT * FROM table1 MERGE table2
```

It will raise error if method is called without argument and tables list contains less than two table.

```ruby
builder.join.to_sql
# => IllegalSQLConstruct: Ambiguous merging clause
```

It will merge first table from tables list with given table if argument exists.

```ruby
builder.merge(:table2).to_sql
# => SELECT * FROM table MERGE table2
```

And it will raise error if number of tables is more than two.

```ruby
builder.from(:table1, :table2).merge(:table3).to_sql
# => IllegalSQLConstruct: Ambiguous merging clause
```

Also, you can define alias for each table, but it doesn't influence on result. Because aliases make sense only for joining tables.

```ruby
builder.from{ table1.as(:table1).merge(table1.as(:table2)) }.to_sql
# => SELECT * FROM table1 MERGE table2
```

Chaining this method will replace previous merge definition.

```ruby
builder.merge(:table1).merge(:table2).to_sql
# => SELECT * FROM table MERGE table2
```

### Grouping of results

Grouping of results by specified attributes or expressions, such as `time(10m)`:

```ruby
builder = Influxdb::Arel::Builder.new(:table)
builder.group{ [time(10.m), host] }.to_sql
# => SELECT * FROM table GROUP BY time(10m), host
```

If you want to fill intervals with no data you should call `fill` method:

```ruby
builder.group{ [time(10.m), host] }.fill(0).to_sql
# => SELECT * FROM table GROUP BY time(10m), host fill(0)
```

Chaining this method will add expression to the grouping set. If you want to override expressions when use `group!` method.

```ruby
builder.group{ time(10.m) }.group(:host).to_sql
# => SELECT * FROM table GROUP BY time(10m), host
builder.group{ time(10.m) }.group!(:host).to_sql
# => SELECT * FROM table GROUP BY host
```

### Ordering of results

Yo can set the ordering of results using `order` method

Possible values:

* `:asc`- Default value. Results will be sorted by ascending order.
* `'asc'`- Results will be sorted by ascending order.
* `:desc`- Results will be sorted by descending order.
* `'desc'`- Results will be sorted by descending order.

```ruby
builder = Influxdb::Arel::Builder.new(:table)
builder.order(:desc).to_sql
builder.order('desc').to_sql
# => SELECT * FROM table ORDER DESC

builder.order(:asc).to_sql
builder.order('asc').to_sql
# => SELECT * FROM table ORDER ASC
```

As well it's possible to use `asc` and `desc` methods

```ruby
builder.asc.to_sql
# => SELECT * FROM table ORDER ASC
builder.desc.to_sql
# => SELECT * FROM table ORDER DESC
```

Inverting of the order direction:

```ruby
builder.asc.invert_order.to_sql
# => SELECT * FROM table ORDER DESC
builder.desc.invert_order.to_sql
# => SELECT * FROM table ORDER ASC
```

Chaining this methods will replace previous order definition.

```ruby
builder.asc.desc.to_sql
# => SELECT * FROM table ORDER DESC
```

### Query conditions

You can specify conditions for query using `where` method

```ruby
builder = Influxdb::Arel::Builder.new(:table)
builder.where(name: 'Undr').to_sql
# => SELECT * FROM table WHERE name = 'Undr'
```

```ruby
builder.where{ name.eq('Undr').or(name.eq('Andrei')) }.to_sql
# => SELECT * FROM table WHERE name = 'Undr' OR name = 'Andrei'
```

Chaining this method will add expression to the condition set. They will join using `AND` boolean expression. If you want to override conditions when use `where!` method.

```ruby
builder.where(name: 'Undr').where{ time.lt(10.h.ago) }.to_sql
# => SELECT * FROM table WHERE name = 'Undr' AND time < (now() - 10h)
builder.where(name: 'Undr').where!{ time.lt(10.h.ago) }.to_sql
# => SELECT * FROM table WHERE time < (now() - 10h)
```

### Limits

You can set a limit for a result set

```ruby
builder = Influxdb::Arel::Builder.new(:cpu_load)
builder.limit(100).to_sql
# => SELECT * FROM cpu_load LIMIT 100
```

## Contributing

1. Fork it ( https://github.com/undr/influxdb-arel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
