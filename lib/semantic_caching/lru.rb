require_relative 'region'

module SemanticCaching
  class LRU

    def initialize(capacity, options)
      @params_scheme = options[:params_scheme]
      @capacity = capacity
      @elems = []
    end

    def get(keys)
      reg, index = nil, nil
      @elems.each_with_index do |_reg, _index|
        if _reg.contain? keys 
           reg, index = _reg, _index
           break
        end
      end

      if reg
        status = \
          if reg.eql? keys
            # puts "LRU equal: #{reg.inspect}"
            :equal
          else
            # puts "LRU Contains: #{reg.inspect}"
            :contains
          end
      else
        status = :miss
        # puts 'LRU MISS'
      end
      [ reg, {status: status} ]
    end

    def set(keys, data)
      reg, index = nil, nil
      @elems.each_with_index do |_reg, _index|
        if _reg.contain? keys 
           reg, index = _reg, _index
           break
        end
      end

      if reg
        @elems.unshift @elems.delete_at(index) 
        reg.data = data
      else
        @elems.pop if @elems.size() >= @capacity
        @elems.unshift Region.new( keys, data, params_scheme: @params_scheme )
      end
    end

  end
end
