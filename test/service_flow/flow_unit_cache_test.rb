require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'
require 'path_constant'
require 'cache'

require 'yaml'

class FlowUnitCacheTest < Minitest::Test
  include FlowCases

  def ntest_dining_flow
    flow = ServiceFlow::Flow.new RawFlows['dining'], :unit
    begin
      100.times do
        flow.start
      end
    rescue
      puts flow.log(:statistic).inspect
      puts flow.cache_log(:statistic).inspect
    end
    puts flow.cache_log(:statistic).inspect
    puts flow.log(:statistic).inspect
  end

  def test_cache_pool
    flow = ServiceFlow::Flow.new RawFlows['dining'], :unit
    1.times do
      flow.start
    end

    puts flow.cache_log(:statistic).inspect
    puts flow.log(:statistic).inspect

  end
end
