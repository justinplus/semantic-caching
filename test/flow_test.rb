require_relative 'test_helper'
require 'semantic_caching/flow'

class FlowTest < Minitest::Test
  include TestHelper

  def setup
    get_data
    @sf = SemanticCaching::Flow.new(@flow)
  end

  def test_overhead
    assert_equal 20+30, @sf.overhead(@sf.front, @sf.back, :invoke_t) 
    assert_equal 5+5, @sf.overhead(@sf.front, @sf.back, :query_t) 
    assert_in_delta 0.2*(20+30) + 0.8*(5+5) + 2*(20+30), @sf.overhead(@sf.front, @sf.back)
  end

  def test_shortest_path
    assert_equal [0,1,2], @sf.shortest_path
  end

end

