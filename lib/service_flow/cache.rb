require 'cache'
require 'service_flow/helper'
require 'service_flow/action'

require 'active_support/core_ext/benchmark'
require 'active_support/json'

module ServiceFlow
  class Cache < Action
    include Helper

    StatusMap = { equal: 1, contain: 2, miss: 3,
                  1 => :equal, 2 => :contain, 3 => :miss }

    attr_reader :actions, :cache, :params_scheme, :lru_clock

    def initialize(action_or_flow, cache, params_scheme)
      @actions, @cache, @params_scheme = action_or_flow, cache, params_scheme
      @log, @cache_log = [], []
      @lru_clock = 0
    end

    def start(msg_or_params, which = 0)
      res = nil
      elapse = Benchmark.ms do
        params = which == 0 ? _bind(msg_or_params, input) : msg_or_params
        res = cached_get params
      end
      @log << elapse
      res
    end

    def first_action
      @actions.respond_to?(:first_action) ? @actions.first_action : @actions
    end

    def input
      # @actions.respond_to?(:first_action) ? @actions.first_action.input : @actions.input
      first_action.input
      # NOTE: the order
    end

    def cached_get(params)
      @lru_clock += 1
      Log.debug "LRU clock: #{lru_clock}"

      json, status = nil, nil

      # time cost of cache query
      Log.debug "Query cache, params: #{params}, key: #{params_to_key(params)}"
      query_elapse = Benchmark.ms do
        sleep( @actions.query_time.to_f / 1000 )
        json, status= cache.get params_to_key(params)
      end

      if json.nil? 
        desc = nil
      else 
        data = JSON.parse json
        desc = ::Cache::Descriptor.new(params, data['content'], data['lru_time'])
        if !desc.lru_time.nil? && desc.lru_time < lru_clock
          Log.debug 'Begin refresh cache'
          refresh_trans = Benchmark.ms do
            data = actions.start(params, 1)
          end
          refresh_caching = Benchmark.ms do
            sleep( @actions.caching_time.to_f / 1000 )
            desc = ::Cache::Descriptor.new(params, data, new_lru_time) 
            cache.set params_to_key(params), desc.to_json
          end
          Log.debug 'End refresh cache'
        end
      end 

      status ||= (desc.nil? ? :miss : :equal)

      refresh_trans ||= 0
      refresh_caching ||= 0
      miss_trans, miss_caching = 0, 0

      case status
      when :equal
        data = desc.content
      when :contain
        # TODO:
        # data = desc.filter status
        data = desc.content
      when :miss
        # time cost of transmission when cache missed
        Log.debug 'Begin handle miss'
        miss_trans = Benchmark.ms do
          data = actions.start(params, 1)
        end
        # NOTE: params here not filtered
        # time cost of set cache
        miss_caching = Benchmark.ms do
          sleep( @actions.caching_time.to_f / 1000 )
          desc = ::Cache::Descriptor.new(params, data, new_lru_time) 
          # data = desc.to_json
          cache.set params_to_key(params), desc.to_json
          # Log.debug "Set cache, data: #{data}"
        end
        Log.debug "End handle miss"
      end

      @cache_log << [ StatusMap[status], cache.size, query_elapse, miss_trans, miss_caching, refresh_trans, refresh_caching]
      desc.content
      
    end

    def params_to_key(params)
      params_scheme.map { |p| [p['name'], params[p['name']]] }.join(':')
    end

    def new_lru_time # TODO
      @actions.refresh_freq == 0 ? nil : lru_clock + ( @actions.invoking_freq / @actions.refresh_freq ).round - 1 # decrease 1 or not
    end

    def log(scope = nil)
      case scope
      when :raw, nil
        @log
      else
        Helper.cnt_sum_avg(@log)
      end
    end

    def cache_log(scope = nil)
      case scope
      when :raw, nil
        @cache_log
      else
        s = Hash.new
        s[:size], s[:count], s[:elapse] = cache.size, Hash.new(0), Hash.new(0)
        # TODO: possibly divided by zero
        s[:count][:query] = @cache_log.size

        @cache_log.each do |log|
          s[:count][StatusMap[log[0]]] += 1
          s[:count][:refresh] += 1 if log[5] > 0

          s[:elapse][:miss_trans] += log[3]
          s[:elapse][:miss_caching] += log[4]
          s[:elapse][:refresh_trans] += log[5]
          s[:elapse][:refresh_caching] += log[6]
          s[:elapse][:query] += log[2]
        end
        s[:avg_elapse] = [:miss, :refresh].each_with_object({}) do |key, ob|
          ob["#{key}_trans".to_sym] = s[:count][key] == 0 ? 0 : s[:elapse]["#{key}_trans".to_sym] / s[:count][key]
          ob["#{key}_caching".to_sym] = s[:count][key] == 0 ? 0 : s[:elapse]["#{key}_caching".to_sym] / s[:count][key]
        end
        s[:avg_elapse][:query] = s[:elapse][:query] / s[:count][:query]

        s[:rate] = [:miss, :refresh].each_with_object({}) do |key, ob|
          ob[key] = s[:count][key].to_f / s[:count][:query]
        end
        s[:rate][:hit] = ( s[:count][:equal] + s[:count][:contain] ).to_f / s[:count][:query]
        s
      end
    end

    def inspect
      <<-INSPECT
==
cache
actions: #{actions.inspect}
#{cache.inspect}
==
      INSPECT
    end
  end
end
