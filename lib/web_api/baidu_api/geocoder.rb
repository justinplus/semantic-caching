require_relative 'baidu_api'

class BaiduAPI
  class Geocoder < BaiduAPI
    attr_accessor :uri

    def initialize
      super
      @path = '/geocoder/v2/'
    end

    def get_location(query)
      self.query = query
    end

    def get_address(query)
      self.query = query
    end

  end
  
end
