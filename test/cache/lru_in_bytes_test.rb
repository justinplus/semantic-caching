require_relative '../test_helper'

require 'cache/lru_in_bytes'

class LRUInBytesTest < Minitest::Test
  
  def setup
  end
  
  def ntest_small_case_1
    lru = Cache::LRUInBytes.new 1
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
    lru = Cache::LRUInBytes.new 3
    lru.set( '1', '111' )
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
