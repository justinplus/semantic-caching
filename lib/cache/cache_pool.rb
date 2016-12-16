module Cache
  class CachePool

    @@aging_threshold = 100
    @@aging_rate = 2

    @@capacity = 1024 * 1024
    @@strategy = :rand

    @@pool = []
    @@benefit = []
    @@counter = []
    @@counter_mutex = Mutex.new

    @@log = []

    def self.aging_threshold
      @@aging_threshold
    end

    def self.aging_threshold=(aging_threshold)
      @@aging_threshold = aging_threshold
    end

    def self.aging_rate
      @@aging_rate
    end

    def self.aging_rate=(aging_rate)
      @@aging_rate = aging_rate
    end

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
      unless [:rand, :bss, :fbss].include? strategy
        raise "Unsupported strategy: #{strategy}"
      end
      @@strategy = strategy
    end

    def self.pool
      @@pool
    end

    def self.benefit
      @@benefit
    end

    def self.counter
      @@counter
    end

    def self.log
      @@log
    end

    def self.size
      @@pool.inject(0){ |sum, c| sum + c.size }
    end

    def self.inner_cache_size
      @@pool.map{ |c| c.size }
    end

    attr_reader :cache

    def initialize(id = nil, lru_class = LRUInBytes, options = {})
      unless id.nil?
        raise ArgumentError.new 'Explicit `id` no longer supported'
      end

      @id = @@pool.size
      @cache = lru_class.new(nil)
      @@pool << @cache
      @@benefit << options.fetch(:benefit, 0)
      @@counter << 0
    end

    def size( global = false )
      if global
        self.class.size
      else
        cache.size
      end
    end

    def get(key)
      @@counter_mutex.synchronize do
        @@counter[@id] += 1
        if @@counter.inject(:+) > @@aging_threshold
          @@counter.map! { |c| c / @@aging_rate }
        end
      end
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
      when :bs
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
      when :fbss
        tmp = []
        @@counter_mutex.synchronize do
          sum = @@counter.inject(:+)
          @@pool.each_with_index do |c, i|
            tmp << [c, (1 + @@counter[i].to_f / sum) * @@benefit[i] / (c.peek.last.bytesize * c.size)] if c.size > 0
          end
        end
        tmp.min_by{ |x| x.last }.first._discard
      else
        raise "Unsupported strategy: #{@@strategy}"
      end
    end

  end
end
