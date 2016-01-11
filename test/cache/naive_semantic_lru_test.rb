require_relative '../test_helper'

require 'cache'

class NaiveSemanticLRUInBytesTest < Minitest::Test
  
  def setup
  end
  
  def ntest_small_case_1
    lru = ::Cache::NaiveSemanticLRUInBytes.new(1)
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
    lru = ::Cache::NaiveSemanticLRUInBytes.new(3)
    lru.set( 'id:1000', '1' )
    lru.set( 'id:2000', '2' )
    lru.set( 'id:3000', '3' )
    puts lru.inspect

    puts lru.get( 'id:1000' ).inspect
    puts lru.inspect
    
    lru.set( 'id:4000', '4' )
    puts lru.inspect

    puts lru.get( 'id:2000' ).inspect
    puts lru.inspect

  end

end
