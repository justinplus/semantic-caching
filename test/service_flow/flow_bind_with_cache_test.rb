require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'

class FlowBindWithCacheTest < Minitest::Test

  def setup
    @weather_flow_raw = YAML.load_file PathConstant::Root.join('multiple/weather.yml')
    @place_detail_flow_raw = YAML.load_file PathConstant::Root.join('multiple/place_detail.yml')
    @dining_flow_raw = YAML.load_file PathConstant::Root.join('multiple/dining.yml')
  end

  def ntest_init_weather
    flow = ServiceFlow::Flow.new @weather_flow_raw
    src = ServiceFlow::OpenWeatherSource.new
    msg = {'area' => {'id' => src.next_v(:uniform)[0]}}
    puts flow.start msg
  end

  def ntest_init_place_detail
    flow = ServiceFlow::Flow.new @place_detail_flow_raw
  end

  def test_init_dining
    weather = ServiceFlow::Flow.new @weather_flow_raw
    place_detail = ServiceFlow::Flow.new @place_detail_flow_raw
    puts weather.start
    puts place_detail.start

    ServiceFlow::ActionRef.add 'weather', weather
    ServiceFlow::ActionRef.add 'place_detail', place_detail
    flow = ServiceFlow::Flow.new @dining_flow_raw

    puts flow.start
    puts Cache::CachePool.log.to_yaml
    puts flow.log(:s).to_yaml
    puts flow.cache_log(:s).to_yaml
  end

end

