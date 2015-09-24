require 'json'
require_relative '../web_api'

class BaiduAPI < WebAPI

  def initialize
    @ak = 'KxOTRGA4NepDS5QTq41wSb9i'
    @uri = URI 'http://api.map.baidu.com'
    @format = 'json'
    @query = { ak: @ak, output: @format }
  end

end
