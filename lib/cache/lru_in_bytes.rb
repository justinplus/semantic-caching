require_relative 'lru'

module Cache
  class LRUInBytes < LRU
    attr_reader :size, :capacity

    def initialize(capacity)
      @size = 0
      super
    end

    def set(key, value)
      raise "The bytesize is larger than capacity" if value.bytesize > capacity

      val = @elems.delete key
      @size -= val.bytesize unless val.nil?

      @elems[key] = value
      @size += value.bytesize

      while @size > @capacity
        @size -= @elems.delete(@elems.first.first).bytesize
      end
    end

  end
end
