module Influxdb
  module Arel
    module Predications
      def not_eq(other)
        Nodes::NotEqual.new(self, other)
      end

      def not_eq_any(others)
        grouping_any(:not_eq, others)
      end

      def not_eq_all(others)
        grouping_all(:not_eq, others)
      end

      def eq(other)
        Nodes::Equality.new(self, other)
      end

      def eq_any(others)
        grouping_any(:eq, others)
      end

      def eq_all(others)
        grouping_all(:eq, others)
      end

      def in(other)
        case other
        when Range
          if other.begin == -Float::INFINITY && other.end == Float::INFINITY
            Nodes::Equality.new(1, 1)
          elsif other.end == Float::INFINITY
            Nodes::GreaterThanOrEqual.new(self, other.begin)
          elsif other.begin == -Float::INFINITY && other.exclude_end?
            Nodes::LessThan.new(self, other.end)
          elsif other.begin == -Float::INFINITY
            Nodes::LessThanOrEqual.new(self, other.end)
          elsif other.exclude_end?
            left = Nodes::GreaterThanOrEqual.new(self, other.begin)
            right = Nodes::LessThan.new(self, other.end)
            Nodes::And.new([left, right])
          else
            left = Nodes::GreaterThanOrEqual.new(self, other.begin)
            right = Nodes::LessThanOrEqual.new(self, other.end)
            Nodes::And.new([left, right])
          end
        else
          Nodes::In.new(self, other)
        end
      end

      def matches(other)
        Nodes::Matches.new(self, other)
      end

      def matches_any(others)
        grouping_any(:matches, others)
      end

      def matches_all(others)
        grouping_all(:matches, others)
      end

      def does_not_match(other)
        Nodes::DoesNotMatch.new(self, other)
      end

      def does_not_match_any(others)
        grouping_any(:does_not_match, others)
      end

      def does_not_match_all(others)
        grouping_all(:does_not_match, others)
      end

      def gteq(right)
        Nodes::GreaterThanOrEqual.new(self, right)
      end

      def gteq_any(others)
        grouping_any(:gteq, others)
      end

      def gteq_all(others)
        grouping_all(:gteq, others)
      end

      def gt(right)
        Nodes::GreaterThan.new(self, right)
      end

      def gt_any(others)
        grouping_any(:gt, others)
      end

      def gt_all(others)
        grouping_all(:gt, others)
      end

      def lt(right)
        Nodes::LessThan.new(self, right)
      end

      def lt_any(others)
        grouping_any(:lt, others)
      end

      def lt_all(others)
        grouping_all(:lt, others)
      end

      def lteq(right)
        Nodes::LessThanOrEqual.new(self, right)
      end

      def lteq_any(others)
        grouping_any(:lteq, others)
      end

      def lteq_all(others)
        grouping_all(:lteq, others)
      end

      private

      def grouping_any(method_id, others)
        nodes = others.map{|expr| send(method_id, expr) }
        Nodes::Grouping.new(nodes.inject{|result, node| Nodes::Or.new(result, node) })
      end

      def grouping_all(method_id, others)
        Nodes::Grouping.new(Nodes::And.new(others.map{|expr| send(method_id, expr) }))
      end
    end
  end
end
