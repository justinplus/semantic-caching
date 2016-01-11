require_relative '../test_helper'

require 'cache'

class CachePoolTest < Minitest::Test

  def setup
    @cnt = 10
    @caches = []
    @cnt.times do |i|
      @caches << ::Cache::CachePool.new("cache_#{i}")
    end

  end

  def ntest_init
    
    assert_equal @cnt, ::Cache::CachePool.pool.size

    @cnt.times do |i|
      assert_equal @caches[i].cache, ::Cache::CachePool.pool[i]
    end

  end

  def test_caching
    20.times do |i|
      @caches.first.set("#{i}", "#{i}"*1024)
      @caches[1].set("#{i}", "#{i}"*1024)
    end

    puts ::Cache::CachePool.pool.inspect
  end

end
