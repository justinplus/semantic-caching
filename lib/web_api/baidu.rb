require_relative 'base'

module WebAPI 
  class Baidu < Base

    def initialize
      @ak = 'KxOTRGA4NepDS5QTq41wSb9i'
      @uri = URI 'http://api.map.baidu.com'
      @format = 'json'
      @query = { ak: @ak, output: @format }
    end

    def search(query)
      if query[:event]
        @path = '/place/v2/eventsearch'
      else
        @path = '/place/v2/search'
      end

      self.query = query
    end

    def search_near_by
    end

    def search_in_bound
    end

    def detail(query)
      @path = '/place/v2/detail'
      self.query = query
    end

    def event_detail(query)
      @path = '/place/v2/eventdetail'
      self.query = query
    end

    def locate(query)
      @path = '/geocoder/v2/' 
      self.query = query
    end

    def direct(query)
      @path = '/direction/v1'
      self.query = query
    end

  end
end
