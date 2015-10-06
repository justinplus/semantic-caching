require_relative 'metrics_test_helper'

module SemanticCaching
  class Flow
    class OpenWeatherSource < Source
      @@table_f = CSV.table '../../data/area_id_f.csv'
      @@table_v = CSV.table '../../data/area_id_v.csv'

      def initialize
        @cur_row_f = -1
        @cur_row_v = -1
      end

      def next_f(random = false)
        if random
          @@table_f[rand(@@table_f.size)]
        else
          @cur_row_f = (@cur_row_f+1) % @@table_f.size
          @@table_f[@cur_row_f]
        end
      end

      def next_v(random = false)
        if random
          @@table_v[rand(@@table_v.size)]
        else
          @cur_row_v = (@cur_row_v+1) % @@table_v.size
          @@table_v[@cur_row_v]
        end
      end

    end
  end
end

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
