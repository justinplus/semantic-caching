require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'

class FlowCombinedCacheTest < Minitest::Test
  include FlowCases

  def setup
    @flow = ::ServiceFlow::Flow.new RawFlows['dining']
  end

  def ntest_run_combined_cache
    @flow.transform! :combined

    # puts @flow.actions.inspect
    # msg = @flow.source.gen_msg(:normal)

    500.times do 
      @flow.start
    end

    puts 'log ==', @flow.log(:statistic).inspect

    puts 'cache log ==', @flow.cache_log(:statistic).inspect

  end

  def test_cache_pool
    size_in_mb = 4
    ::Cache::CachePool.capacity = 1024 * 1024 * size_in_mb
    # ::Cache::CachePool.strategy = :benefit_size

    flow = ServiceFlow::Flow.new RawFlows['dining_lite']
    flow.transform! :combined
    # puts flow.split_scheme.inspect

    times = 0
    begin
      10000.times do
        flow.start
        puts times+=1
        sleep 0.1
      end
    rescue
      puts "error:#{$!} at:#{$@}"
    ensure
      write_res "combined_cache_pool_log_#{size_in_mb}", ::Cache::CachePool.log.to_yaml
      write_res "combined_exec_log_#{size_in_mb}", {stat: flow.log(:s), raw: flow.log}.to_yaml
      write_res "combined_cache_log_#{size_in_mb}", {stat: flow.cache_log(:s), raw: flow.cache_log}.to_yaml
    end

  end

  def write_res(file_name, data)
    File.open(::PathConstant::LogRoot.join("#{file_name}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"), 'w').write(data) 
  end

end
