module Influxdb
  module Arel
    module Quoter
      extend self

      def quote(value)
        block = types[value.class]
        block ? block.call(value) : value.inspect
      end

      def add_type(type, &block)
        types[type] = block
      end

      private

      def types
        @types ||= {}
      end
    end

    Quoter.add_type(String) do |value|
      "'#{value}'"
    end

    Quoter.add_type(Time) do |value|
      value.to_i * 1_000_000
    end

    Quoter.add_type(Date) do |value|
      value.to_i * 1_000_000
    end

    Quoter.add_type(DateTime) do |value|
      value.to_i * 1_000_000
    end

    if defined?(BigDecimal)
      Quoter.add_type(BigDecimal) do |value|
        value.to_s('F')
      end
    end

    Quoter.add_type(NilClass) do |value|
      'null'
    end

    Quoter.add_type(Hash) do |value|
      value = value.to_json if value.respond_to?(:to_json)
      value.to_s
    end

    Quoter.add_type(Nodes::SqlLiteral) do |value|
      value
    end

    if defined?(ActiveSupport::Multibyte::Chars)
      Quoter.add_type(ActiveSupport::Multibyte::Chars) do |value|
        "'#{value}'"
      end
    end

    if defined?(ActiveSupport::StringInquirer)
      Quoter.add_type(ActiveSupport::StringInquirer) do |value|
        "'#{value}'"
      end
    end
  end
end
