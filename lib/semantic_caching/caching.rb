require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash/transform_values'
require 'yaml'

require 'path_constant'

module SemanticCaching
  module Caching

    def get(params)

      region, extra = nil, nil

      elapse = Benchmark.ms do
        region, extra= cache.get params 
      end

      # region.refresh unless region.valid?

      calc(extra[:status], elapse)

      case extra[:status]
      when :equal
        data = region.data
      when :contains
        data = region.filter extra[:filter]
      when :miss
        data = nil
        trans_elapse = Benchmark.ms do
          data = action.start(params)
        end
        miss_elapse = Benchmark.ms do
          cache.set params, data
        end
        puts "get miss"
        calc(:trans, trans_elapse)
        calc(:miss_add, miss_elapse)
      end
    end

    def calc(item, mtime)
      statistic[item] << mtime
    end

    def save_statistic(path = 'statistic')
      pn = SemanticCaching::TestRoot.join('data', path)
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
