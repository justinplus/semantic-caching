require_relative 'metrics_test_helper'
require 'active_support/core_ext/string/filters'

class BaiduMetricsTest < Minitest::Test
  include MetricsTestHelper

  def setup
    @source = SemanticCaching::Flow::BaiduSource.new
    @baidu = WebAPI::Baidu.new
  end

  def search_metrics
    metrics(500, 'baidu_search') do
      @baidu.search q: @source.next_tag_l2, location: @source.next_loc { |long, lat| "#{lat},#{long}"} 
      @baidu.get
    end
  end

  def event_metrics
    metrics(500, 'baidu_event') do
      @baidu.search q: '美食', location: @source.next_loc { |long, lat| "#{lat},#{long}"}, region: '上海', event: 'groupon' 
      @baidu.get
    end
  end

  def detail_metrics
     metrics(500, 'baidu_res_detail') do 
      @baidu.detail uid: @source.next_res_uid, scope: 2
      @baidu.get
    end
  end

  def test_detail_metrics
     metrics(500, 'baidu_res_event_detail') do 
      @baidu.event_detail uid: @source.next_res_uid, scope: 2
      @baidu.get
    end
  end

end
