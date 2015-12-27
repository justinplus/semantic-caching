require_relative 'descriptor'

module SemanticCache
  class LRU
    attr_reader :size, :capacity

    def initialize(capacity, params_scheme)
      @params_scheme = params_scheme
      @capacity = capacity
      @size = 0
      @elems = {}
      @priority = [] 
    end

    def _get(params, elems, cur, flag) 
      if !elems.nil? && cur < @params_scheme.size
        p = @params_scheme[cur]
        if elems[ params[p['name']] ]
          _get(params, elems[params[p['name']]], cur+1, flag)
        elsif p['operator'] == '=='
          nil
        else
          flag.upcase!
          elems.each do |key, val| # huge overhead
            if key.public_send(p.satisfy, params[p['name']])
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
      desc = _get(params, @elems, 0, flag)

      if desc
        @priority.delete_at @priority.each_with_index.find(nil){ |(val, index)| val.object_id == desc.object_id }.last
        @priority << desc
        [ desc, flag == flag.downcase ? :equal : :contain ]
      else
        [ nil, :miss ]
      end
    end

    def set(params, data, ttl = nil)
      while data.bytesize + @size > @capacity
        desc = @priority.shift
        remove_elem(desc.params)
      end

      elems = @elems
      @params_scheme.each_with_index do |p, index|
        if @params_scheme.size - 1 == index
          desc = elems[params[p['name']]]
          if desc
            @priority.delete @priority.each_with_index{ |val, index| val.object_id == desc.object_id } 
            desc.content = data
          else
            desc = Descriptor.new(params, data, ttl)
            elems[params[p['name']]] = desc 
          end
          @priority << desc
        else
          elems = ( elems[params[p.name]] ||= {} )
        end
      end

      @size += data.bytesize
    end

    def refresh(descriptor, data)
      @size = @size - descriptor.data.bytesize + data.bytesize
      descriptor.data = data
      # descriptor.ttl = Time.now + TODO
    end

    def remove_elem(params)
      elems = @elems
      path = [ elems ]
      @params_scheme.each do |p|
        path << elems[ params[p['name']] ]
      end
      desc = path.pop
      path.pop.delete params[ @params_scheme[-1]['name'] ]

      path.reverse.each_with_index do |hsh, index|
        key = params[@params_scheme[index]['name']]
        hsh.delete key if hsh[key].empty?  
      end

      @size -= desc.content.bytesize
    end

    def inspect
      "Size: #{@size}\n" + @elems.inspect + "\n" + @priority.inspect
    end
  end
end
