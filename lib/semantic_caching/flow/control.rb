require_relative 'constant'

module SemanticCaching
  class Flow
    class Fork
      attr_accessor :prev, :succ, :branches
      Metrics.each{ |m| attr_reader m }
      attr_reader :invoke_t

      def initialize(branches)
        @branches = []
        branches.each { |b| @branches << Flow.new(b) }

        @refresh_f = @branches.inject(0){ |s, b| s + b.refresh_f } 
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

