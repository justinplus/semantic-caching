require_relative '../test_helper'

require 'service_flow'

class SourceTest < Minitest::Test

  def test_baidu_source
    radius = CSV.read ::PathConstant::DataRoot.join('radius.csv')
    src = ::ServiceFlow::BaiduSource.new(1, 1, 2, 2, 5)

    10000.times do |i|
      # puts msg = src.gen_msg(:normal)
      assert_equal msg['query']['radius'], radius[i].first.to_i
    end
  end

  
end
