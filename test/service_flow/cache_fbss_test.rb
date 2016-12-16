require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'
require 'path_constant'
require 'cache/params_scheme'

require 'yaml'

class CacheFbssTest < Minitest::Test
  def setup
    @weather_flow_raw = YAML.load_file PathConstant::Root.join('multiple/weather.yml')
    @place_detail_flow_raw = YAML.load_file PathConstant::Root.join('multiple/place_detail.yml')
    @dining_flow_raw = YAML.load_file PathConstant::Root.join('multiple/dining.yml')
  end

  def test_fbss
    Cache::CachePool.capacity = 10000
    Cache::CachePool.strategy = :fbss

    weather = ServiceFlow::Flow.new @weather_flow_raw
    place_detail = ServiceFlow::Flow.new @place_detail_flow_raw
    puts Cache::CachePool.counter.inspect
    puts Cache::CachePool.inner_cache_size.inspect

    weather.start
    weather.start
    weather.start
    weather.start
    puts Cache::CachePool.counter.inspect
    puts Cache::CachePool.inner_cache_size.inspect
    place_detail.start
    puts Cache::CachePool.counter.inspect
    puts Cache::CachePool.inner_cache_size.inspect
    place_detail.start
    puts Cache::CachePool.counter.inspect
    puts Cache::CachePool.inner_cache_size.inspect
  end

end
