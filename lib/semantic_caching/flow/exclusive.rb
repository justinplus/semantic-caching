require_relative 'control'

module SemanticCaching
  class Flow
    class Exclusive < Fork
      def initialize(*branches, prob)
        super *branches

        raise ArgumentError unless prob.inject(:+) == 1;
        @prob = prob

        [:pure_invoke_t, :query_t, :hit_r].each do |m|
          instance_variable_set "@#{m}", @branches.each_with_index.inject(0){ |s, (b, index)| s + @prob[index]*b.send(m) }
        end

        @invoke_t = @branches.each_with_index.inject(0) do |s, (b, index)|
          b.shortest_path
          s + @prob[index]*b.shortest_dist
        end
      end
    end
  end
end

