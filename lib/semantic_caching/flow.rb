require_relative '../web_api'
require_relative 'flow/action'
require_relative 'flow/control'
require 'yaml'
require 'active_support/core_ext/object'

module SemanticCaching

  class Flow
    CacheScheme = [:flow, :unit, 'flow', 'unit']
    attr_reader :raw
    def initialize(flow)
      @raw = flow 
      @elems = @raw.map do |e|
        Object.const_get(e[:type]).new e[:actor], e[:method], e[:args], e[:metrics]
      end
      
      for i in Range(0, len-1, true)
        @elems[i].succ = @elems[i+1]
      end

      for i in Range(1, len, true)
        @elems[i].prev = @elems[i-1]
      end

    end

    def shortest_path # TODO: require testing
      return @shortest_path if @shortest_path

      len = @raw.length
      mat = Array.new(len) { Array.new(len) }
      for i in Range.new(1, len , true)
        for j in Range.new(i, len, true)
          mat[i][j] = overhead(@elems[i-1], @elems[j])
          if i - j == 1 && mat[i][j] > @elems.invoke_t
            mat[i][j] = @elems.invoke_t
          end
        end
      end

      dist = mat[0].zip([]) # integer is immuable in ruby
      dist.first.last = 1
      path = [0]

      (len-1).times do # TODO len or len-1 
        min = dist.inject{ |dist, mark| mark == 1 }.min.last

        path << min

        for i in Range.new(1, len, true)
          if !mark[i] && dist[i] > dist[min] + mat[min][i]
            dist[i] = dist[min] + mat[min][i]
          end
        end

      end

      @shortest_path = path
      @shortest_dist = dist.last
    end

    def cache_scheme=(scheme)
      raise 'Cache scheme cannot be changed once setted!!' if @cache_scheme
      raise ArgumentError, "Cache scheme can only be one of #{CacheScheme}" unless CacheScheme.include scheme
      @cache_scheme = scheme
    end

    def overhead(from, to, metric=nil) # refresh overhead is amplified
      if metrics
        sum = 0
        loop do
          from = from.succ
          sum += from.send metric 
          break if from == to
        end
        sum
      else
        hit_r = from.succ.hit_r
        tt_invoke_t, tt_refresh_f, tt_cache_t = 0, 0, 0
        loop do
          from = from.succ
          tt_invoke_t += from.try(:cahced_invoke_t) || from.invoke_t
          tt_refresh_f += from.refresh_f
          tt_cache_t += from.cache_t
          break if from == to
        end

        tt_invoke_t * (1 - hit_r + tt_refresh_f) + tt_cache_t
      end

    end

    def front
      @elems.first
    end

    def back
      @elems.last
    end

  end
end

