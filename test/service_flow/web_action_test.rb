require_relative '../test_helper'

require 'service_flow/action'
require 'web_api/baidu'

class WebActionTest < Minitest::Test
  TestAction = {
    'baidu' => {
      'type' => 'WebAction',
      'actor' => 'Baidu',
      'method' => 'search',
      'input' => { 
        'lng' => ['origin', 'lng'],
        'lat' => ['origin', 'lat'],
        'q' => ['query', 'q'],
        'radius' => ['query', 'radius']
      },
      'output' => {
        'hotel' => ['results', 0]
      },
      'description' => 'Get a nearby restaurant'
    }
  }

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
    @action = ServiceFlow::WebAction.new( TestAction['baidu'] )
  end

  def test_run
    puts @action.start( TestMsg )
  end

end
