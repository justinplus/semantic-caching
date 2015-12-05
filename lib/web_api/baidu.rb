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
      query['scope'] = 2
      self.query = query
    end

    def event_detail(query)
      @path = '/place/v2/eventdetail'
      self.query = query
    end

    def locate(query)
      lat, lng = query.delete('org_lat'),query.delete('org_lng')
      query['location'] = "#{lat},#{lng}"
      @path = '/geocoder/v2/' 
      self.query = query
    end

    def direct(query)
      lat, lng = query.delete('org_lat'),query.delete('org_lng')
      query['origin'] = "#{lat},#{lng}"
      lat, lng = query.delete('dest_lat'),query.delete('dest_lng')
      query['destination'] = "#{lat},#{lng}"
      # Naive assumption
      query['region'] = query['origin_region'] = query['destination_region'] = '上海'

      @path = '/direction/v1'
      self.query = query
    end

    def query=(query)
      lat = query.delete 'lat'
      lng = query.delete 'lng'
      query['location'] = "#{lat},#{lng}" if lat && lng
      super
    end

  end
end
