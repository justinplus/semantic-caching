require_relative '../test_helper'

require 'web_api'
require 'service_flow'
require 'path_constant'

require 'yaml'

class ExclusiveTest < Minitest::Test
  include PathConstant
  
  TestMsg = {
    'origin' => {
      'lng' => 121.43741570417,
      'lat' => 31.02372204295
    },
    'hotel' => {
      'location' => {
        'lng' => 121.41000130106,
        'lat' => 31.015450122866
      }
    },
    'query' => { 
      'q' => '停车场',
      'radius' => 1000
    }

  }

  def setup
    @exclusive = ServiceFlow::Exclusive.new YAML.load_file( DataRoot.join 'flow_exclusive.yml' )
  end

  def test_execution
    puts @exclusive.start(TestMsg)
  end

end
