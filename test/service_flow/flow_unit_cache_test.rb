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
    size_in_mb = 1
    ::Cache::CachePool.capacity = 1024 * 1024 * size_in_mb

    flow = ServiceFlow::Flow.new RawFlows['dining'], :unit

    times = 0
    begin
      10000.times do
        flow.start
        puts times+=1
        sleep 0.5
      end
    rescue
      puts "error:#{$!} at:#{$@}"
    ensure
      write_res "unit_cache_pool_log_#{size_in_mb}", ::Cache::CachePool.log.to_yaml
      write_res "unit_exec_log_#{size_in_mb}", {raw: flow.log, stat: flow.log(:s)}.to_yaml
      write_res "unit_cache_log_#{size_in_mb}", {raw: flow.cache_log, stat: flow.cache_log(:s)}.to_yaml
    end

  end

  def write_res(file_name, data)
    File.open(::PathConstant::LogRoot.join("#{file_name}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"), 'w').write(data) 
  end

end
