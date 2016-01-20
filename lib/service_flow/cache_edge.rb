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

    # TODO: need test
    def valid_rate
      # rate = 1
      rate = 0
      _from = from.succ
      
      loop do
        # rate *= _from.valid_rate
        rate = _from.valid_rate if rate < _from.valid_rate
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

    def caching_cost
      return nil unless valid_data_dependency?
      super
    end

    def valid_data_dependency?
      _from = from.succ

      # TODO: Bug here
      return true if _from == to && WebAction === _from

      msg = {}
      _from.input.each_value do |val|
        case val
        when Hash
          msg[val['map'].first] = nil 
        when Array
          msg[val.first] = nil 
        end
      end

      _from.output.each_key{ |key| msg[key] = nil } if _from.respond_to? :output

      flow = []
      loop do 
        flow << _from
        break if _from == to
        _from = _from.succ
      end

      _valid_data_dependency? flow, msg
    end

    def _valid_data_dependency?(flow, msg)
      flow.each do |action|
        # puts msg.inspect
        case action
        when Exclusive, Parallel
          action.branches.each do |br|
            return false unless _valid_data_dependency?(br.actions, msg)
          end
        else
          action.input.each_value do |val| 
            # puts msg.has_key?( val.first[1][0] )
            # Bad readability
            return false if val.respond_to?(:first) && !msg.has_key?(val.first.respond_to?(:first) ? val.first[1][0] : val.first)
          end
          action.output.each_key do |key|
            msg[key] = nil
          end
        end
      end

      true
    end
    
  end
end
