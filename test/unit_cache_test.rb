require_relative 'test_helper'
require 'web_api/open_weather'
require 'semantic_caching/caching'
require 'semantic_caching/lru'
require 'semantic_caching/flow/action'
require 'semantic_caching/flow/open_weather_source'
require 'path_constant'

require 'csv'

class OpenWeatherCache
  include SemanticCaching::Caching

  attr_reader :cache, :action
  attr_accessor :statistic

  def initialize(capacity)
    @cache = SemanticCaching::LRU.new capacity, params_scheme: 'open_weather'
    @action = SemanticCaching::Flow::WebAction.new(WebAPI::OpenWeather.new, :forecast_f, {})
    @statistic = Hash.new { |hash, key| hash[key] = Array.new }
  end

end

class UnitCacheTest < Minitest::Test
  def setup
    @source = SemanticCaching::Flow::OpenWeatherSource.new
    @sem_cache = OpenWeatherCache.new 100
  end

  def test_region
    
    region = SemanticCaching::Region.new( {area_id: 101070601}, [1,2], params_scheme: 'open_weather'  )
    
  end

  def test_lru_query_times_fixed

    [50].each do |size|
      sem_cache = OpenWeatherCache.new size
      i = 0
      1000.times do 
        area_id = @source.next_f(:uni)[:area_id]
        puts "area_id: #{area_id}"
        sem_cache.get areaid: area_id 
        sleep 0.1
        puts i+=1
      end
      sem_cache.save_statistic( "stat_n_#{size}_1000" )
      puts "save N size:#{size}"
    end

  end

  def test_lru_cache_size_fixed
  end

end

