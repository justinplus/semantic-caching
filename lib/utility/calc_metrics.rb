require 'yaml'

module Utility
  # TODO: mistake here
  def self.calc_metrics(data)
    stat = data.fetch( :stat, data ).flatten!
    stat.map do |r|
      { hit_rate: 1 - r[:miss].to_f / r[:times],
        query_time: r[:miss_trans] / r[:times],
        caching_time:  r[:refresh_trans] / r[:miss],
      }
    end
  end
end
