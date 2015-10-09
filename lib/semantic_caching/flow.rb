require_relative '../web_api'
require_relative 'flow/action'
require_relative 'flow/control'
require_relative 'flow/source'
require_relative 'flow/baidu_source'
require_relative 'flow/parallel'
require_relative 'flow/exclusive'

require 'active_support/core_ext/object'

module SemanticCaching

  class Flow
    attr_reader :raw
    Metrics.each{ |m| attr_reader m }
    def initialize(flow)
      
      # TODO: not very secure
      if flow.first[:actor]
        @source = nil
      else
        @source = Object.const_get("::SemanticCaching::Flow::#{flow.first[:type]}").new
        flow = flow.drop 1 
      end

      @elems = flow.map do |e|
        Object.const_get("::SemanticCaching::Flow::#{e[:type]}").new e[:actor], e[:method], e[:args], e[:metrics]
      end

      @source.succ = @elems.first if @source

      for i in Range.new(0, length, true)
        @elems[i].succ = @elems[i+1]
      end

      for i in Range.new(1, length, true)
        @elems[i].prev = @elems[i-1]
      end

      @hit_r = self.front.hit_r

      @query_t = self.front.query_t

      @pure_invoke_t = self.overhead(front, back, :pure_invoke_t)

      @refresh_f = self.overhead(front, back, :refresh_f)

    end

    # TODO: 
    def length
      @elems.length
    end

    def shortest_path 
      return @shortest_path if @shortest_path

      # for testing
      unless @mat
        len = @elems.length + 1

        @mat = Array.new(len) { Array.new(len) }
        for i in Range.new(0, len , true)
          for j in Range.new(i+1, len, true)
            overhead(@elems[2], @elems[2])
            @mat[i][j] = overhead(@elems[i], @elems[j-1])
            if j - i == 1 && @mat[i][j] > @elems[i].invoke_t
              @mat[i][j] = @elems[i].invoke_t
            end
          end
        end
      end

      len = @mat.size

      dist = @mat[0].zip([]) # integer is immuable in ruby
      dist.first[1] = 1
      path = [0]

      (len-1).times do # TODO len or len-1
        min = dist.each_with_index.reject{ |(dist, mark), index| mark == 1 }.min.last
        dist[min][1] = 1

        puts dist.inspect
        # puts "the index of min: #{min}"

        # TODO: wrong
        path << min
        break if min == len-1

        for i in Range.new(1, len, true)
          if !dist[i].last && !@mat[min][i].nil? && dist[i].first > dist[min].first + @mat[min][i]
            dist[i][0] = dist[min].first + @mat[min][i]
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
          sum += from.send metric
          break if from == to
          from = from.succ
        end
        sum
      else
        hit_r, tt_query_t = from.hit_r, from.query_t
        tt_invoke_t, tt_refresh_f= 0, 0
        loop do
          tt_invoke_t += from.try(:cahced_invoke_t) || from.invoke_t
          tt_refresh_f += from.refresh_f
          break if from == to
          from = from.succ
        end

        tt_invoke_t * (1 - hit_r + tt_refresh_f) + hit_r*tt_query_t
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
