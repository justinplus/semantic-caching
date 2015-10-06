require_relative '../web_api'
require_relative 'flow/action'
require_relative 'flow/control'
require_relative 'flow/source.rb'
require_relative 'flow/baidu_source.rb'
require 'yaml'
require 'active_support/core_ext/object'

module SemanticCaching

  class Flow
    attr_reader :raw
    def initialize(flow)
      @raw = flow 
      @elems = @raw.map do |e|
        Object.const_get("SemanticCaching::Flow::#{e[:type]}").new e[:actor], e[:method], e[:args], e[:metrics]
      end
      
      for i in Range.new(0, len-1, true)
        @elems[i].succ = @elems[i+1]
      end

      for i in Range.new(1, len, true)
        @elems[i].prev = @elems[i-1]
      end

    end

    def length
      @elems.length
    end

    alias_method :len, :length

    def shortest_path # TODO: require testing
      return @shortest_path if @shortest_path

      mat = Array.new(len) { Array.new(len) }
      for i in Range.new(0, len , true)
        for j in Range.new(i+1, len, true)
          mat[i][j] = overhead(@elems[i], @elems[j])
          if j - i == 1 && mat[i][j] > @elems[j].invoke_t
            mat[i][j] = @elems[j].invoke_t
          end
        end
      end

      puts mat.inspect

      dist = mat[0].zip([]) # integer is immuable in ruby
      dist.first[1] = 1
      path = [0]

      (len-1).times do # TODO len or len-1 
        min = dist.each_with_index.reject{ |(dist, mark), index| mark == 1 }.min.last
        dist[min][1] = 1
        # puts "the index of min: #{min}"

        path << min
        break if min == len-1

        for i in Range.new(1, len, true)
          if !dist[i].last && !mat[min][i].nil? && dist[i].first > dist[min].first + mat[min][i]
            dist[i][0] = dist[min].first + mat[min][i]
          end
        end

      end

      @shortest_dist = dist.last.first
      @shortest_path = path
    end

    def shortest_dist 
      return @shortest_dist if @shortest_dist
      self.shortest_path
      @shortest_dist
    end

    def cache_scheme=(scheme)
      raise 'Cache scheme cannot be changed once setted!!' if @cache_scheme
      raise ArgumentError, "Cache scheme can only be one of #{CacheScheme}" unless CacheScheme.include scheme
      @cache_scheme = scheme
    end

    def overhead(from, to, metric=nil) # refresh overhead is amplified
      if metric
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
          tt_cache_t += from.query_t
          break if from == to
        end

        tt_invoke_t * (1 - hit_r + tt_refresh_f) + hit_r*tt_cache_t
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

