require_relative '../test_helper'

require 'web_api'
require 'service_flow'

class FlowShortestPathTest < Minitest::Test

  def setup
    @flow = ::ServiceFlow::Flow.new YAML.load_file( PathConstant::DataRoot.join('flow_dining.yml') )
  end

  def test_shortest_path
    puts @flow.split_scheme.inspect
  end
end
