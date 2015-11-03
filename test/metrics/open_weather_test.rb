require_relative 'metrics_test_helper'

require 'semantic_caching/flow/open_weather_source'

class OpenWeatherMetricsTest < Minitest::Test
  def setup
    @source = SemanticCaching::Flow::OpenWeatherSource.new
    @open_w = WebAPI::OpenWeather.new
  end
  
  # [:forecast_f, :forecast_v, :index_f, :index_v].each do |m|
  [:index_f].each do |m|

    define_method "test_metrics_#{m}" do

      out_csv = CSV.open "open_weather_#{m}_#{Time.now.strftime("%Y%m%d%H%M")}.csv", 'w'
      realtime, data = nil, nil
      total_realtime, total_data_size = 0, 0

      1000.times do 
        @open_w.query = { type: m, areaid: @source.send( "next_#{m[-1]}", true )[0]}
        realtime = Benchmark.ms do
          data = @open_w.get
        end

        sleep 0.5
        total_realtime += realtime
        total_data_size += data.size

        out_csv << [realtime, data.size]
        puts "#{realtime}, #{data.size}"
      end

      out_csv << [total_realtime, total_data_size]
    end
  end

end
