module SemanticCaching
  class Flow
    class Parallel
      def initialize(branches)
        
        [:pure_invoke_t, :query_t].each do |m|
          instance_variable_set "@#{m}", @branches.map{ |b| b.send m }.max
        end

        # TODO: think again
        @hit_r = @branches.inject(0){ |s, b| s + b.hit_r } / @branches.size

        @invoke_t = @branches.map{ |b| b.shortest_path }.max
      end
    end
  end
end

