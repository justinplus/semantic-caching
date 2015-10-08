require_relative '../test_helper'
require 'semantic_caching/flow'
require 'web_api'
require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/string/filters'
require 'csv'

module MetricsTestHelper
  def metrics(times = 100, file_name = nil, sleep_time = 0.5)
    out_csv = CSV.open "#{file_name}_#{Time.now.strftime("%Y%m%d%H%M")}.csv", 'w' if file_name

    realtime, data = nil, nil
    # total_realtime, total_data_size = 0, 0

    times.times do 
      realtime = Benchmark.ms do
        data = yield
      end

    data.squish!

    # total_realtime += realtime
    # total_data_size += data.size
    puts "#{realtime}, #{data.size}"
    # puts data
    out_csv << [ realtime, data.size ] if file_name

    sleep sleep_time
    end

    # out_csv << [total_realtime, total_data_size] if file_name
  end

end

