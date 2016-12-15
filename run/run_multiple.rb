require 'web_api'
require 'service_flow'

def dump_log(file_name, data)
  File.open(PathConstant::Root.join('multiple_log').join("#{file_name}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"), 'w').write(data)
end

Cache::CachePool.strategy = :bss

@weather_flow_raw = YAML.load_file PathConstant::Root.join('multiple/weather.yml')
@place_detail_flow_raw = YAML.load_file PathConstant::Root.join('multiple/place_detail.yml')
@dining_flow_raw = YAML.load_file PathConstant::Root.join('multiple/dining.yml')


weather = ServiceFlow::Flow.new @weather_flow_raw
place_detail = ServiceFlow::Flow.new @place_detail_flow_raw
ServiceFlow::ActionRef.add 'weather', weather
ServiceFlow::ActionRef.add 'place_detail', place_detail
flow = ServiceFlow::Flow.new @dining_flow_raw

cnt1 = 1
cnt2 = 1

# phase 1
cnt1.times do |i|
  puts i

  cnt2.times do
    flow.start
  end
  weather.start
  place_detail.start
end

# phase 2
cnt1.times do |i|
  puts i

  cnt2.times do
    place_detail.start
  end
  flow.start
  weather.start
end

# phase 3
cnt1.times do |i|
  puts i

  cnt2.times do
    weather.start
  end
  flow.start
  place_detail.start
end

dump_log "cache_pool_log", Cache::CachePool.log.to_yaml

dump_log "flow_exec_log", {stat: flow.log(:s), raw: flow.log}.to_yaml
dump_log "flow_cache_log", {stat: flow.cache_log(:s), raw: flow.cache_log}.to_yaml

dump_log "weather_exec_log", {stat: weather.log(:s), raw: weather.log}.to_yaml
dump_log "weather_cache_log", {stat: weather.cache_log(:s), raw: weather.cache_log}.to_yaml

dump_log "place_detail_exec_log", {stat: place_detail.log(:s), raw: place_detail.log}.to_yaml
dump_log "place_detail_cache_log", {stat: place_detail.cache_log(:s), raw: place_detail.cache_log}.to_yaml








