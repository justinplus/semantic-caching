require 'web_api'
require 'service_flow/action'
require 'service_flow/control'
require 'service_flow/source'
require 'service_flow/parallel'
require 'service_flow/exclusive'

require 'active_support/core_ext/object'

module ServiceFlow
  class Flow
    attr_reader :raw
    Metrics.each{ |m| attr_reader m }
    def initialize(flow)

      # TODO: not very secure
      if flow.first['actor']
        @source = nil
      else
        @source = Object.const_get("::ServiceFlow::#{flow.first['type']}").new
        flow = flow.drop 1
      end

      @actions = flow.map do |action|
        Object.const_get("::ServiceFlow::#{action['type']}").new action
      end

      @source.succ = @actions.first if @source

      @actions.each_with_index do |action, index|
        action.succ = @actions[index+1] if index != @actions.length
        action.prev = @actions[index-1] if index != 0
      end

      # @hit_r = self.front.hit_r

      # @query_t = self.front.query_t

      # @pure_invoke_t = self.overhead(front, back, :pure_invoke_t)

      # @refresh_f = self.overhead(front, back, :refresh_f)

    end

    def start(msg)
      msg ||= @source.gen_msg

      @actions.each do |action|
        msg.merge! action.start(msg)
        puts msg
      end

      msg
    end

    def log
      @actions.map{ |action| action.log }
    end

    # TODO:
    def length
      @actions.length
    end

    def shortest_path
      return @shortest_path if @shortest_path

      # for testing
      unless @mat
        len = @actions.length + 1

        @mat = Array.new(len) { Array.new(len) }
        for i in Range.new(0, len , true)
          for j in Range.new(i+1, len, true)
            overhead(@actions[2], @actions[2])
            @mat[i][j] = overhead(@actions[i], @actions[j-1])
            if j - i == 1 && @mat[i][j] > @actions[i].invoke_t
              @mat[i][j] = @actions[i].invoke_t
            end
          end
        end
      end

      len = @mat.size

      dist = @mat[0].zip([]) # integer is immuable in ruby
      dist.first[1] = 1
      path = @mat[0].map{ |e| e.nil? ? nil : 0 }
      path[0] = nil

      (len-1).times do
        min = dist.each_with_index.reject{ |(dist, mark), index| mark == 1 || dist.nil? }.min.last
        dist[min][1] = 1

        puts dist.inspect

        break if min == len-1

        for i in Range.new(1, len, true)
          if !dist[i].last && !@mat[min][i].nil? && (dist[i].first.nil? || dist[i].first > dist[min].first + @mat[min][i] )
            dist[i][0] = dist[min].first + @mat[min][i]
            path[i] = min
          end
        end

      end

      @shortest_path = [len-1]
      while path[@shortest_path.first]
        @shortest_path.unshift( path[@shortest_path.first] )
      end

      @shortest_dist = dist.last.first
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
      @actions.first
    end

    def back
      @actions.last
    end

    private
    def _shortest_path(start = 0, nodes = [front], path = [])
      while start < nodes.size do
        shortest = _overhead(start, nodes)
        path.each_with_index do |val, index| 
          tmp = path[index] + _overhead(index, nodes)
          shortest = tmp if shortest > tmp # Attn: > or >=
        end

        path << shortest
        nodes << start.succ if start.succ
        start += 1
      end
    end

  end
end
