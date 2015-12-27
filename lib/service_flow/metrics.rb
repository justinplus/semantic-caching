require 'yaml'

require 'service_flow/action'
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

  class WebAction < Action
    module Metrics
      include ServiceFlow::Metrics

      BASIC_METRIC_NAMES.each do |m|
        define_method m do
          METRICS[actor.class.to_s.split('::').last][method][m]
        end
      end

      def valid_rate
        1 - refresh_freq.to_f / invoking_freq
      end

      def invalid_rate
        refresh_freq.to_f / invoking_freq
      end

    end
  end

  class Flow
    module Metrics
      include ServiceFlow::Metrics

      [ 'hit_rate', 'query_time', 'caching_time' ].each do |m|
        define_method m do 
          actions.first.public_send m
        end
      end

      def invalid_rate
        1 - valid_rate
      end

      def valid_rate
        actions.inject(1) { |prod, n| prod * n.valid_rate }
      end

      def invoking_time
        actions.inject(0) { |sum, n| sum + n.invoking_time }
      end

    end
  end
end

