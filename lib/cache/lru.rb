module Cache
  class LRU
    def initialize(capacity)
      @capacity = capacity
      @elems = {}
    end

    def size
      @elems.size
    end

    def get(key)
      val = @elems.delete key
      if val
        @elems[key] = val
      else
        nil
      end
    end

    def set(key, value)
      @elems.delete key
      @elems[key] = value
      @elems.delete @elems.first.first if @elems.size > @capacity 
    end

    def inspect
      <<-inspect
====
Size: #{size}
====
Elems: #{@elems}
====
      inspect
    end

  end
end
