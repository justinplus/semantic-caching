require 'net/http'
require 'openssl'
require 'base64'

appid = 'a057f18208f763ae'
private_key = 'f2528f_SmartWeatherAPI_d59bd6c'

uri = URI 'http://open.weather.com.cn/data/'

query = {
  areaid: 101010100,
  type: 'forecast_f',
  date: Time.now.strftime("%Y%m%d%H%M"),
  appid: appid
}

uri.query = URI.encode_www_form query
  
digest = OpenSSL::Digest.new 'sha1'
hamc = OpenSSL::HMAC.digest(digest, private_key, uri.to_s)
puts "public_key: #{uri}"
key = Base64.strict_encode64 hamc
puts "key: #{key}"
query[:appid] = appid[0, 6] 
query[:key] = key

uri.query = URI.encode_www_form query
puts "url: #{uri}"

res = Net::HTTP.get(uri)
puts res

