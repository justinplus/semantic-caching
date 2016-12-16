module Cache
  class CachePool

    @@capacity = 1024 * 1024
    @@strategy = :rand

    @@pool = []
    @@map = {}
    @@benefit = []

    @@log = []

    def self.capacity
      @@capacity
    end

    def self.capacity=(capacity)
      @@capacity = capacity
    end

    def self.strategy
      @@strategy
    end

    def self.strategy=(strategy)
      @@strategy = strategy
    end

    def self.pool
      @@pool
    end

    def self.map
      @@map
    end

    def self.benefit
      @@benefit
    end

    def self.log
      @@log
    end

    def self.size
      @@pool.inject(0){ |sum, c| sum + c.size }
    end

    attr_reader :cache

    def initialize(id = nil, lru_class = LRUInBytes, options = {})
      @id = id
      if @id.nil?
        @id = @@pool.size
      else
        @@map[id] = @@pool.size
      end
      @cache = lru_class.new(nil)
      @@pool << @cache
      @@benefit << options.fetch(:benefit, 0)
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
      raise "The bytesize is larger than capacity" if value.bytesize > @@capacity

      while size(true) + value.bytesize > @@capacity
        # TODO: record replacement times
        discard
      end

      cache._set(key, value)
      @@log << @@pool.map{ |c| c.size }
    end

    def discard
      case @@strategy
      when :rand
        tmp = @@pool.select { |c| c.size > 0 }
        tmp[rand(tmp.size)]._discard
      when :benefit_size, :bs
        tmp = []
        @@pool.each_with_index do |c, i|
          tmp << [c, @@benefit[i] / c.peek.last.bytesize] if c.size > 0
        end
        tmp.min_by{ |x| x.last }.first._discard
      when :bss
        tmp = []
        @@pool.each_with_index do |c, i|
          tmp << [c, @@benefit[i] / (c.peek.last.bytesize * c.size)] if c.size > 0
        end
        tmp.min_by{ |x| x.last }.first._discard
      end
    end

  end
end
