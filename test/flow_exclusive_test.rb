require_relative 'test_helper'
require 'semantic_caching/flow'

class ExclusiveTest < Minitest::Test
  include FlowTestCases

  def setup
    @prob = [0.5, 0.5]
    @p = SemanticCaching::Flow::Exclusive.new BaiduFlow, WeatherFlow, @prob
    @branches = [BaiduFlow, WeatherFlow]
  end

  def test_hit_r
    assert_equal @branches.each_with_index.inject(0){ |s, (br, index)| s + @prob[index] * br.first[:metrics]['hit_r'] }, @p.hit_r
  end

  def test_pure_invoke_t
    assert_equal @branches.each_with_index.inject(0){ |s, (br, index)| s + @prob[index] * br.inject(0){ |s, act| s + act[:metrics]['pure_invoke_t'] } } , @p.pure_invoke_t
  end

  def test_query_t
    assert_equal @branches.each_with_index.inject(0){ |s, (br, index)| s + @prob[index] * br.first[:metrics]['query_t'] }, @p.query_t
  end

end

