require_relative '../test_helper'

require 'semantic_cache/lru'

class LRUTest < Minitest::Test
  
  def setup
  end
  
  def ntest_small_case_1
    lru = SemanticCache::LRU.new(1, [ {'name' => 'id', 'operator' => '=='}] )
    lru.set( {'id' => 1}, '1' )
    puts lru.inspect
    puts lru.get( {'id' => 1} ).inspect
    puts lru.get( {'id' => 2} ).inspect

    lru.set( {'id' => 2}, '1' )
    puts lru.inspect
    puts lru.get( {'id' => 1} ).inspect
    puts lru.get( {'id' => 2} ).inspect
  end

  def test_small_case_2
    lru = SemanticCache::LRU.new(3, [ {'name' => 'id', 'operator' => '=='}] )
    lru.set( {'id' => 1}, '1' )
    lru.set( {'id' => 2}, '1' )
    lru.set( {'id' => 3}, '1' )
    puts lru.inspect

    puts lru.get( {'id' => 1} ).inspect
    puts lru.inspect
    
    lru.set( {'id' => 4}, '1' )
    puts lru.inspect

    puts lru.get( {'id' => 2} ).inspect
    puts lru.inspect

  end

end
