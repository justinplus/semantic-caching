require_relative '../test_helper'

require 'web_api'
require 'service_flow'

class MetricsTest < Minitest::Test

  ITEMS_TO_CHECK = ['hit_rate', 'valid_rate', 'invoking_time', 'query_time', 'caching_time', 'caching_cost']

  def setup
    @dining_flow = YAML.load_file(PathConstant::DataRoot.join('flow_dining.yml'))
    @weather_flow = YAML.load_file(PathConstant::DataRoot.join('flow_weather.yml'))
    @exclusive_flow = YAML.load_file(PathConstant::DataRoot.join('flow_exclusive.yml'))
    @parallel_flow = YAML.load_file(PathConstant::DataRoot.join('flow_parallel.yml'))
  end

  def tst_web_action
    action = ::ServiceFlow::WebAction.new @dining_flow[1]
    check action
  end

  def tst_flow
    flow = ::ServiceFlow::Flow.new @weather_flow
    check flow
  end

  def tst_exclusive
    exclusive = ::ServiceFlow::Exclusive.new @exclusive_flow
    check exclusive
  end

  def test_parallel
    parallel = ::ServiceFlow::Parallel.new @parallel_flow
    check parallel
  end

  def check(object)
    ITEMS_TO_CHECK.each do |i|
      puts "#{i}: #{object.public_send(i)}"
    end
  end


end
