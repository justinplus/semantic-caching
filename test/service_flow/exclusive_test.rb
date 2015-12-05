require_relative '../test_helper'

require 'web_api'
require 'service_flow'
require 'path_constant'

require 'yaml'

class ParallelTest < Minitest::Test
  include PathConstant

  TestMsg = { 
    'origin' => {
      'lat' => '39.915',
      'lng' => '116.414'
    },
    'query' => { 
      'q' => '饭店',
      'radius' => 1000
    },
    'area_id' => 101020100
  }

  def setup
    @parallel = ServiceFlow::Parallel.new YAML.load_file( DataRoot.join 'flow_parallel.yml' )
  end

  def test_execution
    puts @parallel.start(TestMsg)
  end

end
