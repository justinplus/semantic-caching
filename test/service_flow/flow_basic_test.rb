require_relative '../test_helper.rb'

require 'web_api'
require 'service_flow'
require 'path_constant'

require 'yaml'

class FlowTest < Minitest::Test
  include PathConstant

  TestMsg = { 
    'origin' => {
      'lat' => '39.915',
      'lng' => '116.414'
    },
    'query' => { 
      'q' => '饭店',
      'radius' => 1000
    }
  }

  def setup
  end

  def ntest_execution
    @flow_seq = ServiceFlow::Flow.new YAML.load_file( DataRoot.join 'flow_seq.yml' )
    @flow_seq.start TestMsg
    puts @flow_seq.log.inspect
  end

  def ntest_weather_flow
    @flow_weather = ServiceFlow::Flow.new YAML.load_file( DataRoot.join 'flow_weather.yml' )
    @flow_weather.start TestMsg
  end

  def test_dining_flow
    @flow_dining = ServiceFlow::Flow.new YAML.load_file( DataRoot.join 'flow_dining.yml' )
    @flow_dining.start TestMsg
  end
end

