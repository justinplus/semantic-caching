require_relative 'metrics_test_helper'
require 'json'

class BaiduGetUidTest < Minitest::Test
  def setup
    @source = SemanticCaching::Flow::BaiduSource.new
    @baidu = WebAPI::Baidu.new
  end

  def uid(times = 100, file_name = nil)
    out_csv = CSV.open "#{file_name}_#{Time.now.strftime("%Y%m%d%H%M")}.csv", 'w' if file_name

    times.times do
      data = yield

      if data['results']
        data = data['results'].map { |r| [r['name'], r['uid']] }
        data.each do |r|
          out_csv << r
        end
      end
    end

  end

  def restaurant_uid
    uid(100, 'baidu_restaurant_uid') do
      @baidu.search q: '餐厅', location: @source.next_loc { |long, lat| "#{lat},#{long}"} 
      JSON.parse @baidu.get
    end
  end

  def test_uid
    uid(200, 'baidu_uid') do
      @baidu.search q: @source.next_tag_l2, location: @source.next_loc { |long, lat| "#{lat},#{long}"} 
      JSON.parse @baidu.get

    end
  end

end

