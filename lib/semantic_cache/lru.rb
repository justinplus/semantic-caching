require_relative 'region'

module SemanticCache
  class LRU
    attr_reader :size, :capacity

    def initialize(capacity, options)
      @params_scheme = options[:params_scheme]
      @capacity = capacity
      @size = 0
      @elems = {}
      @priority = LinkedList::List.new
    end

    def _get(params, elems, cur, flag) 
      if cur < @params_scheme.size
        p = @params_scheme[cur]
        if params[p.name]
          _get(params, elems[params[p.name]], cur+1, flag)
        else
          flag.upcase!
          elems.each do |key, val| # huge overhead
            if key.public_send(p.satisfy, params[p.name])
              res = _get(params, val, cur+1, flag)
              break res if res
            end
          end
        end
      else
        elems
      end
    end

    def get(params)
      flag = 'a'
      node = _get(params, @elems, 0, flag)

      if node
        @priority.delete node
        @priority.append node
        [ node.data, flag.downcase? :equal : :contain ]
      else
        [ nil, :miss ]
      end

    end

    def set(params, data)
      while data.bytesize + @size > @capacity
        @size -= @priority.unshift.data.bytesize
      end

      elems, tmp = @elems, nil
      @params_scheme.each_with_index do |p, index|
        if @params_scheme.size - 1 == index
          elems = ( elems[params[p.name]] ||= {} )
        else
          elems[params[p.name] = data
        end
      end
    end

    def refresh(descriptor, data)
      @size = @size - descriptor.data.bytesize + data.bytesize
      descriptor.data = data
      # descriptor.ttl = Time.now +  TODO
    end

  end
end
