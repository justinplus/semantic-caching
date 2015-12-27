require 'active_support/core_ext/enumerable'

module Analysis 
  def avg(data)
    data.map do |item|
      if item.first.respond_to? :map
        avg(item)
      else
        [item.size, item.size == 0 ? 0 : item.sum/item.size]
      end
    end
  end

  def merge_avg(data1, data2) 
    res = []
    _merge_avg( data1, data2, res )
    res
  end

  def _merge_avg(data1, data2, res)
    for i in Range.new( 0, data1.size, true)
      curr1, curr2 = data1[i], data2[i]
      if curr1.first.respond_to? :map
        res << []
        _merge_avg(curr1, curr2, res.last)
      else
        sum = curr1.first + curr2.first
        res << [ sum, 
                 sum == 0 ? 0 : (curr1.first * curr1.last + curr2.first * curr2.last ) / sum ] 
      end
    end
  end
end
