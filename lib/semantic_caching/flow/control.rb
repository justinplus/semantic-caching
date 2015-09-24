module SemanticCaching
  class Flow
    class Fork
      attr_accessor :prev, :succ, :branches

      def initialize(prev=nil)
        @prev = prev
      end

      def fork(branch)
        @branches << branch
      end

      def start
        @branches.each do |b|
          b.start
        end
      end

    end

    class Join
      attr_accessor :prev, :succ

      def start
      end
      
    end

    class Async
    end

  end
end

