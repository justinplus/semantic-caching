require 'yaml'

require 'path_constant'

module ServiceFlow

  METRICS = YAML.load_file PathConstant::DataRoot.join('metrics.yml')

  BASIC_METRIC_NAMES = ['hit_rate', 'refresh_freq', 'invoking_time', 'query_time', 'caching_time', 'invoking_freq']

  module Metrics
    def caching_cost(rough = false)
      _rate = 1 - hit_rate * valid_rate
      _tmp = _rate * invoking_time
      # _tmp = ( hit_rate * (1 - valid_rate) + (1 - hit_rate) ) * invoking_time
      rough ? _tmp : _tmp + _rate * caching_time + query_time
      # rough ? _tmp : _tmp + ( (1-hit_rate) + hit_rate * (1-valid_rate) ) * caching_time + query_time
    end
  end

end

