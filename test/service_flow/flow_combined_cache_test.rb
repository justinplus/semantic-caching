require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'

class FlowCacheSplitTest < Minitest::Test
  include FlowCases

  def setup
    @flow = ::ServiceFlow::Flow.new RawFlows['dining']
  end

  def test_run_combined_cache
    @flow.transform! :combined

    # puts @flow.actions.inspect
    # msg = @flow.source.gen_msg(:normal)

    500.times do 
      @flow.start
    end

    puts 'log ==', @flow.log(:statistic).inspect

    puts 'cache log ==', @flow.cache_log(:statistic).inspect

  end

end
