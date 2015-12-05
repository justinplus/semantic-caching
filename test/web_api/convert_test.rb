require_relative '../test_helper'

require 'web_api/convert'

class ConvertTest < Minitest::Test
  def setup
    @convert = WebAPI::Convert.new
  end

  def test_open_weather
    @convert.open_weather(name_en: 'shanghai')
    puts @convert.get
  end
end
