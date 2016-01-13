require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'

class FlowCacheSplitTest < Minitest::Test
  include FlowCases

  def setup
    @flow = ::ServiceFlow::Flow.new RawFlows['dining']
  end

  def ntest_shortest_path
    puts @flow.split_scheme.inspect
    # puts @flow.actions[1].invoking_time,
      # @flow.actions[1].valid_rate
    # puts @flow.actions[1].branches[1].valid_rate
  end

  def ntest_cache_split
    @flow.transform! :combined
    puts @flow.actions.inspect
  end

  def test_run_combined_cache
    @flow.transform! :combined
    # puts @flow.actions[0].params_scheme
    # puts @flow.actions[1].params_scheme
    @flow.start
  end

end
