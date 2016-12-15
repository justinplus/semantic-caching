require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'

class FlowCacheSplitTest < Minitest::Test
  include FlowCases

  def setup
    @flow = ::ServiceFlow::Flow.new RawFlows['dining_lite']
  end

  def ntest_shortest_path
    puts @flow.split_scheme.inspect
    puts @flow.shortest_dist
    # puts @flow.actions[1].invoking_time,
      # @flow.actions[1].valid_rate
    # puts @flow.actions[1].branches[1].valid_rate
  end

  def ntest_cache_split
    @flow.transform! :combined
    puts @flow.actions.inspect
  end

  def ntest_unit_transform
    @flow.transform! :unit
    puts @flow.actions.inspect
    puts Cache::CachePool.benefit.inspect
  end

  def ntest_run_combined_cache
    @flow.transform! :combined
    # puts @flow.actions[0].params_scheme
    # puts @flow.actions[1].params_scheme
    puts Cache::CachePool.benefit.inspect
    puts Cache::CachePool.pool
    puts @flow.actions.inspect
  end

  def ntest_open_weather_source
    src = ServiceFlow::OpenWeatherSource.new
    10000.times do
      n =  src.next_id_v :nm
      # puts n.inspect
    end
  end

  def test_open_weather_source
    src = ServiceFlow::PlaceSource.new
    10000.times do
      n =  src.next_id :nm
      puts n.inspect
    end
  end



end
