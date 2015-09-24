require_relative 'base'

module WebAPI
  class JuHe < Base

    def initialize
      @key = nil
      @uri = URI 'http://v.juhe.cn'
      @dtype = 'json'
      @query = { key: @key, dtype: @dtype }
    end

    def weather(query)
      if query[:lon]
        @path = '/weather/geo'
      else
        @path = '/weather/index'
      end

      self.query = query
    end

    def forecast_3h(query)
      @path = 'weather/forecast4h.php'
      self.query = query
    end

  end
end
