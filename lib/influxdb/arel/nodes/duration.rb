module Influxdb
  module Arel
    module Nodes
      class Duration < Binary
        POSSIBLE_SUFFIXES = %w{u s m h d w}.freeze

        alias :value :left
        alias :suffix :right

        def initialize(value, suffix)
          suffix = suffix.to_s
          suffix = 'u' unless POSSIBLE_SUFFIXES.include?(suffix)
          super(value.to_i, suffix)
        end

        def time
          Time.new(self)
        end

        def ago
          Now.new - self
        end

        def since
          Now.new + self
        end
      end
    end
  end
end
