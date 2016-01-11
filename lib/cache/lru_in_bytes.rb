require_relative 'lru'

module Cache
  class LRUInBytes < LRU
    attr_reader :size, :capacity

    def initialize(capacity)
      @size = 0
      @semaphore = Mutex.new
      super
    end

    def set(key, value)
      @semaphore.synchronize do
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

    def _set(key, value)
      @semaphore.synchronize do
        val = @elems.delete key
        @size -= val.bytesize unless val.nil?

        @elems[key] = value
        @size += value.bytesize
      end

    end

    def _discard
      @semaphore.synchronize do
        @size -= @elems.delete(@elems.first.first).bytesize
      end
    end

  end
end
