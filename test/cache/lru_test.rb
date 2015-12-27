require_relative '../test_helper'

require 'semantic_cache/lru'

class LRUTest < Minitest::Test
  
  def setup
  end
  
  def ntest_small_case_1
    lru = SemanticCache::LRU.new(1, [ {'name' => 'id', 'operator' => '=='}] )
    lru.set( '1', '1' )
    puts lru.inspect
    puts lru.get( '1' ).inspect
    puts lru.get( '2' ).inspect

    lru.set( '2', '1' )
    puts lru.inspect
    puts lru.get( '1' ).inspect
    puts lru.get( '2' ).inspect
  end

  def test_small_case_2
    lru = SemanticCache::LRU.new(3, [ {'name' => 'id', 'operator' => '=='}] )
    lru.set( '1', '1' )
    lru.set( '2', '1' )
    lru.set( '3', '1' )
    puts lru.inspect

    puts lru.get( '1' ).inspect
    puts lru.inspect
    
    lru.set( '4', '1' )
    puts lru.inspect

    puts lru.get( '2' ).inspect
    puts lru.inspect

  end

end
