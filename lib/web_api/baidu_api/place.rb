require_relative 'baidu_api'

class BaiduAPI 
  class Place < BaiduAPI

    def initialize 
      super
      @base_path = '/place/v2'
    end

    def path=(path)
      @path = @base_path + path.to_s
    end

    def search(query)
      if query[:event]
        self.path = '/eventsearch'
      else
        self.path = '/search'
      end

      self.query = query
      # self.get
    end

    def search_near_by
    end

    def search_in_bound
    end

    def detail(query)
      self.path = '/detail'
      self.query = query
      # self.get
    end

    def event_detail(query)
      self.path = '/eventdetail'
      self.query = query
      # self.get
    end

  end

end

