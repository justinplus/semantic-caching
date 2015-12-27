module ServiceFlow

  class Action
    attr_accessor :succ, :prev
    attr_reader :log

    def initialize(prev, succ)
      @prev, @succ = prev, succ
    end
  end

end

