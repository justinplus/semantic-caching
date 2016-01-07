require_relative '../test_helper'
require_relative 'flow_cases'

require 'service_flow'
require 'path_constant'

class CacheEdgeTest < Minitest::Test
  include FlowCases

  def test_data_dependency
    f = ::ServiceFlow::Flow.new RawFlows['dining']
    assert_equal true, ::ServiceFlow::CacheEdge.new( f.actions[0], f.actions[1]).valid_data_dependency?
    refute_nil ::ServiceFlow::CacheEdge.new( f.actions[0], f.actions[1]).caching_cost

    assert_equal true, ::ServiceFlow::CacheEdge.new( ::ServiceFlow::Action.new(nil, f.actions[0]), f.actions[1]).valid_data_dependency?

    br = f.actions[1].branches[0]
    assert_equal true, ::ServiceFlow::CacheEdge.new( ::ServiceFlow::Action.new(nil, br.actions[0]), br.actions[1]).valid_data_dependency?

    br = f.actions[1].branches[1]
    assert_equal false, ::ServiceFlow::CacheEdge.new( ::ServiceFlow::Action.new(nil, br.actions[0]), br.actions[3]).valid_data_dependency?
  end

end
