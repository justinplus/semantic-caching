module Cache

  # Naive semantic LRU cache for Baidu web action of method search
  module NaiveSemantic
    RadiusRange = [1000, 2000, 3000, 4000, 5000]

    def get(key)
      # naive assuming that the last 4 char stand for radius
      res = super(key)
      return [ res, :equal ] if res
      index = RadiusRange.find_index(key[-4..-1].to_i)
      for i in Range.new(index + 1, RadiusRange.size, true)
        key[-4..-1] = RadiusRange[i].to_s
        res = @elems.delete key
        if res
          @elems[key] = res
          return [res, :contain]
        end
      end

      nil
    end

  end

  class NaiveSemanticLRU < LRU
    include NaiveSemantic
  end

  class NaiveSemanticLRUInBytes < LRUInBytes
    include NaiveSemantic
  end



end
