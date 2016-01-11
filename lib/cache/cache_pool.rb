module Cache
  class CachePool
    Capacity = 1024 * 100
    Strategy = :rand

    @@pool = []
    @@map = {}

    def self.pool
      @@pool
    end

    def self.map
      @@map
    end

    def self.size
      @@pool.inject(0){ |sum, c| sum + c.size }
    end

    attr_reader :cache
    
    def initialize(id = nil, lru_class = LRUInBytes)
      @id = id
      if @id.nil?
        @id = @@pool.size
      else
        @@map[id] = @@pool.size
      end
      @cache = lru_class.new(nil)
      @@pool << @cache
    end

    def size( global = false )
      if global
        self.class.size
      else
        cache.size
      end
    end

    def get(key)
      cache.get(key)
    end

    def set(key, value)
      raise "The bytesize is larger than capacity" if value.bytesize > Capacity

      while size(true) + value.bytesize > Capacity
        discard
      end

      cache._set(key, value)
    end

    def discard
      case Strategy
      when :rand
        tmp = @@pool.select { |c| c.size > 0 }
        tmp[rand(tmp.size)]._discard
      when :priority

      end
    end

  end
end
