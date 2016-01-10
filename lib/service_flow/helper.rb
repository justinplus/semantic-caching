require 'active_support/core_ext/enumerable'

module ServiceFlow
  module Helper
    def _bind(data, mapping)
      mapping.each_with_object({}) do |(key, val), hsh|
        hsh[key] = 
          case val
          when Array 
            val.inject(data) { |m, k| m[k] } 
          when Hash
            tmp = val['map'].inject(data) { |m, k| m[k] } 
            # the postprocess should return new value
            tmp.public_send *val['post']
          else
            val
          end
      end
    end

    def self.cnt_sum_avg(ary)
        sum = ary.sum
        cnt = ary.size.to_f
        avg = cnt == 0 ? 0 : sum / cnt
        # puts avg
        # puts 'ary', ary.inspect
        var = cnt == 0 ? 0 : ary.each_with_object([0]) { |t, ob| ob[0] += (t-avg)*(t-avg) }[0] / cnt
        { cnt: cnt, sum: sum, avg: avg, var: var}
    end
  end
end
