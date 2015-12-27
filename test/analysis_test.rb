require 'json'

require 'active_support/core_ext/enumerable'

require 'analysis'
require 'path_constant'
require_relative 'test_helper'

class AnalysisTest < Minitest::Test
  include Analysis, PathConstant

  def setup
    @in_f = File.open DataRoot.join('flow_dining_metrics.txt')
  end

  def atest_avg
    data = JSON.parse @in_f.readline 
    puts avg(data).inspect
  end

  def test_merge_avg
    res = nil
    @in_f.each_line do |l|
      avgs = avg( JSON.parse l )
      res = res.nil? ? avgs : merge_avg(res, avgs)
    end

    puts res.inspect
  end

end
