require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash/transform_values'
require 'yaml'

require 'path_constant'

module SemanticCache
  module Caching

    def get(params)

      descriptor, extra = nil, nil

      elapse = Benchmark.ms do
        descriptor, status= cache.get params 
      end

      log(status, elapse)

      case status
      when :equal
        data = descriptor.content
      when :contain
        data = descriptor.filter status
      when :miss
        trans_elapse = Benchmark.ms do
          data = action.start(params)
        end
        miss_elapse = Benchmark.ms do
          cache.set params, data
        end
        puts "get miss"
        log(:trans, trans_elapse)
        log(:miss_add, miss_elapse)
      end
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

    def inspect
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
