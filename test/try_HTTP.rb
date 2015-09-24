require 'net/http'
require 'json'
require 'benchmark'

host = 'www.baidu.com'
path = ""

uri = URI('http://apis.baidu.com/apistore/weatherservice/citylist');
uri.query = URI.encode_www_form ({cityname: '上海'})

req = Net::HTTP::Get.new(uri) 
req['apikey'] = 'fad5fb972ccbeff6bf06cd99e8f3a060'

res = nil
puts Benchmark.measure do
  res = Net::HTTP.start(uri.hostname, uri.port) { |h| h.request(req) }
end

puts JSON.parse(res.body)
