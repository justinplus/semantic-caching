require_relative '../test_helper'

require 'web_api'
require 'service_flow'

class FlowCacheSplitTest < Minitest::Test

  def setup
    @flow = ::ServiceFlow::Flow.new YAML.load_file( PathConstant::DataRoot.join('flow_dining.yml') )
  end

  def test_shortest_path
    puts @flow.split_scheme.inspect
  end

  def ntest_cache_split
    @flow.transform! :combined
    puts @flow.source
    puts @flow.actions.inspect

  end

  def ntest_run_combined_cache
    @flow.transform! :combined
    @flow.start
  end

end
