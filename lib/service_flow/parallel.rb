require 'service_flow/control'

module ServiceFlow
  class Parallel < Fork
    def initialize(branches_or_options, cache_mode = nil)
      # puts branches_or_options
      branches = case branches_or_options
                 when Hash
                   branches_or_options['branches']
                 else
                   branches_or_options
                 end
      super branches, cache_mode
      # NOTE: difference of:
      # super branches

      # [:pure_invoke_t, :query_t].each do |m|
      # instance_variable_set "@#{m}", @branches.map{ |b| b.send m }.max
      # end

      # # TODO: think again
      # @hit_r = @branches.inject(0){ |s, b| s + b.hit_r } / @branches.size

      # @invoke_t = @branches.map{ |b| b.shortest_path }.max
    end

    def _start(msg)
      threads = []

      @branches.each do |br|
        threads << Thread.new { br.start(msg) }
      end

      threads.each do |th|
        msg.merge! th.value
      end
      msg
    end

  end
end
