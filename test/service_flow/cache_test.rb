require_relative '../test_helper'

require 'web_api'
require 'service_flow'
require 'path_constant'

require 'yaml'

class CacheTest < Minitest::Test
  include PathConstant 

  def setup
    @params_scheme = YAML.load_file(DataRoot.join('params_scheme.yml'))
  end

  def ntest_cache
    action = ::ServiceFlow::WebAction.new YAML.load_file(DataRoot.join('flow_weather.yml'))[2]
    cache = ::ServiceFlow::Cache.new action, ::Cache::LRU.new(100), @params_scheme['OpenWeather']['forecast_v']
    source = ::ServiceFlow::OpenWeatherSource.new
    100.times do
      cache.start( { 'area' => { 'id' => source.next_f(:uni)[0] } } )
    end

    puts cache.cache_log
    puts cache.inspect

  end

  def test_naive_semantic_cache
    action = ::ServiceFlow::WebAction.new YAML.load_file(DataRoot.join('flow_dining.yml'))[1]
    cache = ::ServiceFlow::Cache.new action, ::Cache::NaiveSemanticLRU.new(100), @params_scheme['Baidu']['search']

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

end
