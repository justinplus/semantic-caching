module SemanticCaching
  class Flow
    class Action
      attr_accessor :actor, :succ, :prev, :meta
    end

    class WebAction < Action
      attr_accessor :method, :parameter

      def initialize(actor, method, options=nil)
        @actor, @method = actor, method
        
        @parameter = options[:parameter]
        @meta = options[:meta]
      end

      def start
        @actor.send @method, @parameter
        @actor.get_result
      end
      
    end

  end
end

