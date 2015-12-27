require_relative '../test_helper'

require 'web_api'
require 'service_flow'
require 'path_constant'
require 'cache'

require 'yaml'

class FlowUnitCacheTest < Minitest::Test
  include PathConstant

  def test_dining_flow
    flow = ServiceFlow::Flow.new YAML.load_file( DataRoot.join 'flow_dining.yml' ), :unit
    begin
      2.times do
        flow.start
      end
    rescue
      puts flow.log(:statistic).inspect
      puts flow.cache_log(:statistic).inspect
    end
      puts flow.cache_log(:statistic).inspect
      puts flow.log(:statistic).inspect
  end
end
