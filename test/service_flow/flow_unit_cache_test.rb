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
    ::Cache::CachePool.capacity = 1024 * 10
    flow = ServiceFlow::Flow.new RawFlows['dining'], :unit
    times = 0
    20.times do
      flow.start
      puts times+=1
    end

    puts flow.cache_log(:s).inspect
    # puts flow.log(:statistic).inspect
    # puts ::Cache::CachePool.log.inspect
    puts ::Cache::CachePool.pool.map{|c| c.size}
    
    write_res @flow_dining.log, @flow_dining.log(:s)

  end

  def write_res(raw, stat)
    File.open(LogRoot.join("unit_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"), 'w').write( {raw: raw, stat: stat}.to_yaml)
  end

end
