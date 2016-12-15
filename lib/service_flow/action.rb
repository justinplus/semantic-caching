module ServiceFlow

  class Action
    attr_accessor :prev, :succ
    attr_reader :log

    def initialize(prev, succ)
      @prev, @succ = prev, succ
    end

    def self.build(hash)
      Object.const_get("::ServiceFlow::#{hash['type']}").new hash
    end
  end

end

