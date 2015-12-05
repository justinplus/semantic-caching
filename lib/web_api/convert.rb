require 'web_api/base'

module WebAPI
  class Convert < Base
    def initialize
      @uri = URI 'http://localhost:3000/'
      @path = '/'
      @query = {}
    end

    def open_weather(query)
      self.query = query
    end
  end
end
