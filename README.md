# Influxdb::Arel

Influxdb::Arel is a SQL AST manager for Influxdb dialect. It simplifies the generation of complex SQL queries.

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

```ruby
events = Influxdb::Arel::Table.new(:events)
events.to_sql
# => SELECT * FROM events
```

## Contributing

1. Fork it ( https://github.com/undr/influxdb-arel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
