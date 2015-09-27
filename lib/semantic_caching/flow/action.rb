require_relative 'constant'

module SemanticCaching
  class Flow
    class Action
      attr_accessor :actor, :succ, :prev
    end

    class WebAction < Action
      attr_accessor :method, :args
      Metrics.each { |m| attr_accessor m }
      alias_method :invoke_t, :pure_invoke_t

      def initialize(actor, method, args, options=nil)
        @actor, @method, @args = actor, method, args
        if options
          Metrics.each { |m| self.send "#{m}=", options[m.to_s] }
        end
      end

      def start
        @actor.send @method, @args
        @actor.get
      end
  
      def metrics 
        Hash[ Metrics.map { |m| [m, self.send(m)] } ]
      end

    end
  end
end

