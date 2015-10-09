require_relative 'test_helper'
require 'semantic_caching/flow'

class ParallelTest < Minitest::Test
  include FlowTestCases
  
  def setup
    @p = SemanticCaching::Flow::Parallel.new BaiduFlow, WeatherFlow
    @branches = [BaiduFlow, WeatherFlow]
  end

  def test_hit_r
    assert_equal @branches.inject(0){ |s, br| s + br.first[:metrics]['hit_r'] } / @branches.size, @p.hit_r
  end

  def test_pure_invoke_t 
    assert_equal @branches.map{ |b| b.inject(0){ |s, act| s + act[:metrics]['pure_invoke_t'] } }.max, @p.pure_invoke_t
  end

  def test_query_t
    assert_equal @branches.map{ |b| b.first[:metrics]['query_t'] }.max, @p.query_t
  end

end

