module SemanticCaching
  class Flow
    Metrics = [:hit_r, :invoke_t, :query_t, :refresh_f]

    class Action
      attr_accessor :actor, :succ, :prev
    end

    class WebAction < Action
      attr_accessor :method, :args
      Metrics.each { |m| attr_accessor m }

      def initialize(actor, method, args, options=nil)
        @actor, @method, @args = actor, method, args
        if options
          Metrics.each { |m| self.send "#{m}=", options[m] }
        end
      end

      def start
        @actor.send @method, @args
        @actor.get
      end
  
      def metrics 
        Hash[ Metrics.map { |m| [m, self.send m] }]
      end

    end
  end
end

