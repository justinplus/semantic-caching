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
    
    @flow_dining = ServiceFlow::Flow.new YAML.load_file( DataRoot.join 'flow_dining.yml' )

    times = 0
    begin
      10000.times do
        @flow_dining.start 
        puts times+=1
        sleep(0.1)
      end
    rescue
      write_res @flow_dining.log, @flow_dining.log(:s)
    end

    write_res @flow_dining.log, @flow_dining.log(:s)

  end

  def write_res(raw, stat)
    File.open(LogRoot.join("unit_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"), 'w').write( {raw: raw, stat: stat}.to_yaml)
  end
end

