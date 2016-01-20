require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'
require 'path_constant'
require 'cache/params_scheme'

require 'yaml'

class CacheTest < Minitest::Test
  include FlowCases

  def setup
  end

  def ntest_naive_semantic_cache
    action = ::ServiceFlow::WebAction.new RawFlows['dining'][1]
    cache = ::ServiceFlow::Cache.new action, ::Cache::NaiveSemanticLRU.new(100), ::Cache::ParamsScheme['Baidu']['search']

    # source = ::ServiceFlow::BaiduSource.new *[121.297198, 31.209686, 121.489795, 31.074682]
    source = ::ServiceFlow::BaiduSource.new *[121.397198, 31.209686, 121.409795, 31.174682], 3

    500.times do
      cache.start source.gen_msg(:normal)
    end

    puts cache.cache_log(:statistic)
    # puts cache.inspect

  end

  # TODO
  def ntest_cache_flow
    source = ::ServiceFlow::BaiduSource.new *[121.397198, 31.209686, 121.409795, 31.174682], 4
    1000.times {puts source.gen_msg(:normal).inspect}
  end

  def ntest_cache_in_bytes
    action = ::ServiceFlow::WebAction.new RawFlows['weather'][2]
    cache = ::ServiceFlow::Cache.new action, ::Cache::LRUInBytes.new(5*1024), ::Cache::ParamsScheme['OpenWeather']['forecast_v']
    source = ::ServiceFlow::OpenWeatherSource.new

    100.times do
      sleep 0.5
      cache.start( { 'area' => { 'id' => source.next_f(:local)[0] } } )
      puts cache.cache.inspect
    end

    puts cache.cache_log(:statistic).inspect
    # puts cache.inspect
  end

  def test_cache_log
    action = ::ServiceFlow::WebAction.new RawFlows['weather'][2]
    cache = ::ServiceFlow::Cache.new action, ::Cache::LRUInBytes.new(5*1024), ::Cache::ParamsScheme['OpenWeather']['forecast_v']

    cache.instance_eval { @cache_log = YAML.load_file(::PathConstant::LogRoot.join('dining_lite', 'unit_cache_log_4_20160115_003948.yml'))[:raw][0] }
    puts cache.cache_log(:s).to_yaml

    cache.instance_eval { @cache_log = YAML.load_file(::PathConstant::LogRoot.join('dining_lite', 'combined_cache_log_4_20160115_061733.yml'))[:raw][0] }
    puts cache.cache_log(:s).to_yaml



  end

end
