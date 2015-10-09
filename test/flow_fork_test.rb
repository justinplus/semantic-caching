require_relative 'test_helper'
require 'semantic_caching/flow'

require_relative 'flow_test_cases'

class ForkTest < Minitest::Test
  include FlowTestCases

  def test_refresh_f
    fork = SemanticCaching::Flow::Fork.new BaiduFlow, WeatherFlow

    assert_equal [BaiduFlow, WeatherFlow].inject(0){ |s, flow| s + flow.inject(0){ |s, act| s + act[:metrics]['refresh_f'] } }, fork.refresh_f
  end

end
