require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash/transform_values'
require 'yaml'

require 'path_constant'

module Cache
  module Caching

    def cached_get(params, log = true)
      desc, status = nil, nil

      # time cost of cache query
      query_elapse = Benchmark.ms do
        desc, status= cache.get params_to_key(params)
      end

      status ||= :equal

      trans_elapse, miss_elapse = 0, 0

      case status
      when :equal
        data = desc.content
      when :contain
        data = desc.filter status
      when :miss
        # time cost of transmission when cache missed
        trans_elapse = Benchmark.ms do
          data = actions.start(params)
        end
        # time cost of set cache
        miss_elapse = Benchmark.ms do
          cache.set params_to_key(params), data
        end
      end

      cache_log << [status, query_elapse, trans_elapse, miss_elapse] if log

    end

    def params_to_key
      params_scheme.map { |p| params[p['name']] }.join(':')
    end

    def log(item, mtime)
      statistic[item] << mtime
    end

    def save_statistic(path = 'statistic')
      pn = SemanticCache::TestRoot.join('data', path)
      File.open("#{pn}_#{Time.now.strftime('%Y%m%d%H%M%S')}.yml", 'w') do |file|
        file.write(YAML.dump(statistic.transform_values { |val| {count: val.size, sum: val.sum, val: val} }))
      end
    end

    def statistic
      statistic.each do |item, t_arr|
        puts <<-STR
#{item}: ------
Times: #{t_arr.size}
Sum: #{t_arr.sum}
Valus: #{t_arr}
        STR
      end
    end

  end
end
