require_relative 'control'

module ServiceFlow
  class Exclusive < Fork
    def initialize(branches_or_options, cond = nil, prob = nil) 
      branches, @cond, @prob = case branches_or_options
                               when Hash
                                 branches_or_options.values_at 'branches', 'condition', 'probabilities'
                               else
                                 [branches_or_options, cond, prob]
                               end

      super branches

      # raise ArgumentError unless prob.inject(:+) == 1;
      # @prob = prob

      # [:pure_invoke_t, :query_t, :hit_r].each do |m|
      # instance_variable_set "@#{m}", @branches.each_with_index.inject(0){ |s, (b, index)| s + @prob[index]*b.send(m) }
      # end

      # @invoke_t = @branches.each_with_index.inject(0) do |s, (b, index)|
      # b.shortest_path
      # s + @prob[index]*b.shortest_dist
      # end
    end

    def start(msg)
      msg.merge! choose_branch(msg).start(msg)
    end

    def choose_branch(msg)
      @branches[0]
    end

  end
end
