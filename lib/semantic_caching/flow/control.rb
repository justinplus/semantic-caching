module SemanticCaching
  class Flow
    class Fork
      attr_accessor :prev, :succ, :branches
      
      Metrics.each{ |m| attr_reader m }

      def initialize(branches)
        branches.each { |b| @branches << Flow.new(b) }
        Metrics.each do |m|
          instance_variable_set "@#{m}", @branches.inject(0){ |s, b|s + b.overhead(b.front, b.back, m) }
        end
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

