require 'web_api'
require 'service_flow'

# dump helprs
def dump_log(file_name, data, phase = nil)
  file = phase.nil? ? "#{file_name}.yml" : "#{file_name}_#{phase}.yml"
  File.open(@log_path.join(file), 'w').write(data)
end

def dump_cache_pool_log
  dump_log "cache_pool_log", Cache::CachePool.log.to_yaml
end

def dump_exec_cache_stat(phase)
  %w( dining weather place_detail ).each do |name|
    dump_log "#{name}_exec_stat", instance_variable_get("@#{name}").log(:s).to_yaml, phase
    dump_log "#{name}_cache_stat", instance_variable_get("@#{name}").cache_log(:s).to_yaml, phase
  end
end

def dump_exec_cache_log
  %w( dining weather place_detail ).each do |name|
    dump_log "#{name}_exec_log", instance_variable_get("@#{name}").log.to_yaml
    dump_log "#{name}_cache_log", instance_variable_get("@#{name}").cache_log.to_yaml
  end
end

# precess options
@share_mode = ARGV[0]
raise "Invalid param share_mode: `#{@share_mode}`!" unless ['shared', 'isolated'].include? @share_mode
@strategy = ARGV[1]
raise "Invalid param strategy: `#{@strategy}`!" unless ['rand', 'bss', 'fbss', 'f0bss'].include? @strategy
@capacity = Float(ARGV[2]).to_i

# set strategy & capacity
Cache::CachePool.strategy = @strategy.to_sym
Cache::CachePool.capacity = 1024 * 1024 * @capacity

# prepare folders
time_str = Time.now.strftime('%Y%m%d_%H%M%S');
@log_path = PathConstant::Root.join('multiple_log').join("#{@share_mode}-#{@strategy}-#{@capacity}-#{time_str}")
@log_path.mkdir

# prepare flows
@weather_flow_raw = YAML.load_file PathConstant::Root.join('multiple/weather.yml')
@place_detail_flow_raw = YAML.load_file PathConstant::Root.join('multiple/place_detail.yml')
@dining_flow_raw = YAML.load_file PathConstant::Root.join('multiple/dining.yml')

weather = ServiceFlow::Flow.new @weather_flow_raw
place_detail = ServiceFlow::Flow.new @place_detail_flow_raw
ServiceFlow::ActionRef.add 'weather', weather
ServiceFlow::ActionRef.add 'place_detail', place_detail
dining = ServiceFlow::Flow.new @dining_flow_raw

@weather, @place_detail, @dining = weather, place_detail, dining

if( @share_mode == 'isolated' )
  weather_2 = ServiceFlow::Flow.new @weather_flow_raw
  place_detail_2 = ServiceFlow::Flow.new @place_detail_flow_raw
  @weather, @place_detail = weather_2, place_detail_2
end

cnt1 = 1
cnt2 = 1

# phase 1
begin
  cnt1.times do |i|
    puts i

    cnt2.times do
      @dining.start
    end
    @weather.start
    @place_detail.start
  end
ensure
  dump_exec_cache_stat 'p1'
  dump_cache_pool_log
  dump_exec_cache_log
end

# phase 2
begin
  cnt1.times do |i|
    puts i

    cnt2.times do
      @place_detail.start
    end
    @dining.start
    @weather.start
  end
ensure
  dump_exec_cache_stat 'p2'
  dump_cache_pool_log
  dump_exec_cache_log
end

# phase 3
begin
  cnt1.times do |i|
    puts i

    cnt2.times do
      @weather.start
    end
    @dining.start
    @place_detail.start
  end
ensure
  dump_exec_cache_stat 'p3'
  dump_cache_pool_log
  dump_exec_cache_log
end
