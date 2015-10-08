require 'web_api/baidu'
require 'json'

b = WebAPI::Baidu.new

addr = '上海交通大学闵行校区电院3号楼'
b.locate address: addr  
orig = JSON.parse( b.get )['result']
puts orig

b.search q: '美食', location: "#{orig['location']['lat']},#{orig['location']['lng']}", scope: 2
des = JSON.parse( b.get )['results'].first
puts des 

b.search q: '停车场', location: "#{des['location']['lat']},#{des['location']['lng']}", scope: 2
park = JSON.parse( b.get )['results'].first
puts park 

b.direct mode: 'walking', origin: "#{orig['location']['lat']},#{orig['location']['lng']}", destination: des['location'].values.join(','), region: '上海'
puts b.get
