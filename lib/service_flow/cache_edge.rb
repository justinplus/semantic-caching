module ServiceFlow
  class CacheEdge
    include ServiceFlow::Metrics

    attr_reader :from, :to
    
    # Node from is not included in calculation
    def initialize(from, to)
      @from, @to = from, to
    end

    [ 'hit_rate', 'query_time', 'caching_time' ].each do |m|
      define_method m do 
        from.succ.public_send m
      end
    end

    def invalid_rate
      1 - valid_rate
    end

    def valid_rate
      rate = 1
      _from = from.succ
      
      loop do
        rate *= _from.valid_rate
        break rate if _from == to
        _from = _from.succ
      end 
    end

    def invoking_time
      sum = 0
      _from = from.succ

      loop do
        sum += _from.invoking_time
        break sum if _from == to
        _from = _from.succ
      end
    end
    
  end
end
