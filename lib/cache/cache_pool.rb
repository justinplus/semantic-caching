module Cache
  class CachePool
    Capacity = 1024*1024
    Strategy = :rand

    @@pool = []
    @@map = {}
    
    attr_reader :pool
  
    def initialize(id, lru_class)
      @id = id
      @@map[id] = @@pool.size
      @@pool << lru_class.new(nil)
    end

    def get(key)
      cache.get(key)
    end

    def set(key, value)
      while size + value.bytesize > Capacity
        discard
      end

      cache._set(key, value)

    end

    def size
      @@pool.inject(0){ |sum, c| sum + c.size }
    end

    def discard
      case Strategy
      when :rand
        @@pool[rand(@@pool.size)]._discard
      when :priority

      end
    end
  end
end
