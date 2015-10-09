require_relative 'test_helper'
require 'semantic_caching/flow'

require_relative 'flow_test_cases'

class FlowTest < Minitest::Test
  include FlowTestCases

  def setup
    @baidu_flow = SemanticCaching::Flow.new BaiduFlow
    @weather_flow = SemanticCaching::Flow.new WeatherFlow
  end

  def test_refresh_f
    assert_equal BaiduFlow.inject(0){ |s, act| s + act[:metrics]['refresh_f'] }, @baidu_flow.refresh_f

    assert_equal WeatherFlow.inject(0){ |s, act| s + act[:metrics]['refresh_f'] }, @weather_flow.refresh_f
  end

  def test_hit_r
    assert_equal BaiduFlow.first[:metrics]['hit_r'], @baidu_flow.hit_r
  end

  def test_query_t
    assert_equal BaiduFlow.first[:metrics]['query_t'], @baidu_flow.query_t
  end

  def test_pure_invoke_t
    assert_equal BaiduFlow.inject(0){ |s, act| s + act[:metrics]['pure_invoke_t'] }, @baidu_flow.pure_invoke_t
  end

  def overhead
    assert_equal 20+30, @sf.overhead(@sf.front, @sf.back, :invoke_t) 
    assert_equal 5+5, @sf.overhead(@sf.front, @sf.back, :query_t) 
    assert_in_delta 0.2*(20+30) + 0.8*(5+5) + 2*(20+30), @sf.overhead(@sf.front, @sf.back)
  end

  def test_shortest_path
    @baidu_flow.instance_eval do
      @mat = [
        [ nil, 2, 1, 10 ],
        [ nil, nil, 3, nil ],
        [ nil, nil, nil, 4 ],
        [ nil, nil, nil, nil ]
      ]
    end

    assert_equal 5, @baidu_flow.shortest_dist
    assert_equal [0,1,3], @baidu_flow.shortest_path
  end

end

