module Influxdb
  module Arel
    module Attributes
      class Attribute < Struct.new(:relation, :name)
        include Expressions
        include Predications
        include AliasPredication
        include Math

        def self.encode(value)
          "'#{value.to_s}'"
        end
      end

      class Time < Attribute
        def self.encode(value)
          value.to_i * 1_000_000
        end
      end

      class Date < Time; end
      class DateTime < Time; end

      class BigDecimal < Attribute
        def self.encode(value)
          value.to_s('F')
        end
      end

      class Boolean < Attribute
        def self.encode(value)
          value.inspect
        end
      end

      class FalseClass < Boolean; end
      class TrueClass < Boolean; end

      class Float < Attribute
        def self.encode(value)
          value
        end
      end

      class Integer < Attribute
        def self.encode(value)
          value
        end
      end

      class Regexp < Attribute
        def self.encode(value)
          value.inspect
        end
      end

      class Hash < Attribute
        def self.encode(value)
          value = value.to_json if value.respond_to?(:to_json)
          super(value)
        end
      end

      class NilClass < Attribute
        def self.encode(value)
          'null'
        end
      end
    end

    Attribute = Attributes::Attribute
  end
end

