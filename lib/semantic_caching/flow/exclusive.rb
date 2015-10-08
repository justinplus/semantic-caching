module SemanticCaching
  class Flow
    class Exclusive
      def initialize(branches, prob)
        
        raise ArgumentError unless prob.sum == 1;
        @prob = prob
        
        [:pure_invoke_t, :query_t, :hit_r].each do |m|
          instance_variable_set "@#{m}", @branches.each_with_index.inject(0){ |s, (b, index)| s + @prob[index]*b.overhead(b.front, b.back, m) }
        end

        @invoke_t = @branches.each_with_index.inject(0) do |s, (b, index)|
          b.shortest_path
          s + @prob[index]*b.shortest_dist
        end
      end
    end
  end
end

