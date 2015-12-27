require 'web_api'
require 'service_flow/action'
require 'service_flow/control'
require 'service_flow/source'
require 'service_flow/parallel'
require 'service_flow/exclusive'
require 'service_flow/helper'
require 'service_flow/cache_edge'
require 'cache'

require 'active_support/core_ext/object'

module ServiceFlow
  class Flow
    include Metrics

    attr_reader :actions, :msg 
    attr_accessor :source

    alias_method :message, :msg

    def initialize(flow, cache_mode = nil)

      # TODO: not very secure
      if flow.first['actor']
        @source = nil
      else
        @source = Object.const_get("::ServiceFlow::#{flow.first['type']}").new( *flow.first['init_args'])
        flow = flow.drop 1
      end

      case cache_mode
      when :unit, 'unit'
        @actions = flow.map do |action|
          case action['type']
          when 'WebAction'
            actor = action['actor']
            method = action['method']
            cache =  actor == 'Baidu' && method == 'search' ? ::Cache::NaiveSemanticLRU.new(1000) : ::Cache::LRU.new(1000)
            ::ServiceFlow::Cache.new ::ServiceFlow::WebAction.new( action), cache, ::Cache::ParamsScheme[actor][method]
          else
            Object.const_get("::ServiceFlow::#{action['type']}").new action, :unit
          end
        end
      else
        @actions = flow.map do |action|
          Object.const_get("::ServiceFlow::#{action['type']}").new action
        end
      end

      @source.succ = @actions.first if @source

      @actions.each_with_index do |action, index|
        action.succ = @actions[index+1] if index != @actions.length
        action.prev = @actions[index-1] if index != 0
      end

      @log = []
    end

    def start(msg = nil)
      msg ||= @source.gen_msg(:normal)
      @msg = msg.clone

      lapse = Benchmark.ms do
        @actions.each do |action|
          msg.merge! action.start(msg)
          # puts msg
        end
      end
      
      @log << lapse

      msg
    end

    def log(scope = nil)
      log = @actions.map{ |action| action.log(scope) }
      log.unshift (scope.nil? || scope == :raw)  ? @log : Helper.cnt_sum_avg(@log)
      # NOTE
    end

    def cache_log(scope = nil)
      @actions.each_with_object([]) do |action, ob|
        ob << action.cache_log(scope) if action.respond_to? :cache_log
      end
    end


    # Source and End node is excluded
    def length
      @actions.length
    end

    def shortest_path
      return @shortest_path if @shortest_path

      # for testing
      unless @mat
        _len = actions.length + 1
        _actions = [ Action.new(nil, actions.first) ] + actions 

        @mat = Array.new(_len) { Array.new(_len) }
        for i in Range.new(0, _len , true)
          for j in Range.new(i+1, _len, true)
            @mat[i][j] = CacheEdge.new(_actions[i], _actions[j]).caching_cost
            _tmp = _actions[j].respond_to?(:caching_cost) ? _actions[j].caching_cost : _actions[j].invoking_time
            if j - i == 1 && @mat[i][j] > _tmp
              @mat[i][j] = _tmp
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
      @shortest_path
    end

    def shortest_dist
      return @shortest_dist if @shortest_dist
      self.shortest_path
      @shortest_dist
    end

    alias_method :caching_cost, :shortest_dist

    def split_scheme
      scheme = { self: shortest_path }
      scheme[:sub] = actions.map do |action| 
        action.respond_to?(:split_scheme) ? action.split_scheme : nil
      end
      scheme
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
