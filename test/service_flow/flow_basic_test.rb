require_relative '../test_helper.rb'

require 'web_api'
require 'service_flow'
require 'path_constant'

require 'active_support/json'

require 'yaml'

class FlowTest < Minitest::Test
  include PathConstant

  TestMsg = { 
    'origin' => {
      'lat' => '30.921146',
      'lng' => '121.579123'
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
    # f_metrics = File.open( DataRoot.join('flow_dining_metrics.txt'), 'a')
    # f_msgs = File.open( DataRoot.join('flow_dining_msgs.txt'), 'a')
    
    msgs = []
    @flow_dining = ServiceFlow::Flow.new YAML.load_file( DataRoot.join 'flow_dining.yml' )
    begin
      100.times do
        @flow_dining.start 
      end

    rescue
      puts @flow_dining.log(:statistic).inspect
      # f_metrics << @flow_dining.log.to_json
      # f_metrics << "\n"
      # f_msgs << msgs.to_json
      # f_msgs << "\n" 
      # f_metrics.close
      # f_msgs.close
    end
    
    puts @flow_dining.log(:statistic).inspect

  end
end

