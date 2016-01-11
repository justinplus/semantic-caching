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
        var_sum = ary.inject(0) { |sum, t| sum + (t-avg)*(t-avg) } 
        varp = cnt <= 1 ? 0 : var_sum / cnt
        vara = cnt <= 1 ? 0 : var_sum / (cnt-1)
        { cnt: cnt, sum: sum, avg: avg, varp: varp, vara: vara}
    end
  end
end
