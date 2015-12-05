require 'web_api/base'
require 'openssl'
require 'base64'

module WebAPI
  class OpenWeather < Base

    def initialize
      @appid = 'a057f18208f763ae'
      @private_key = 'f2528f_SmartWeatherAPI_d59bd6c'
      @uri = URI 'http://open.weather.com.cn'
      @path = '/data/'
      @digest = OpenSSL::Digest.new 'sha1'
      @query = {}
    end

    def forecast(query)
      self.query = query
    end

    def forecast_f(query)
      @query[:type] = 'forecast_f'
      self.query = query
    end

    def forecast_v(query)
      @query[:type] = 'forecast_v'
      self.query = query
    end

    def index(query)
      self.query = query
    end

    def index_f(query)
      @query[:type] = 'index_f'
      self.query = query
    end

    def index_v(query)
      @query[:type] = 'index_v'
      self.query = query
    end

    def query=(query)
      @query[:date] = Time.now.strftime("%Y%m%d%H%M")
      @query[:appid] = @appid # Attn
      @query.delete :key
      @query.merge! query
      public_key = @uri.scheme + '://'.freeze + @uri.host + @path + '?'.freeze + URI.encode_www_form(@query)
      hamc = OpenSSL::HMAC.digest(@digest, @private_key, public_key)
      key = Base64.strict_encode64 hamc
      @query[:appid] = @query[:appid][0, 6]
      @query[:key] = key

      super {}
    end
  
  end
end
