require 'cache'
require 'service_flow/helper'
require 'service_flow/action'

require 'active_support/core_ext/benchmark'
require 'active_support/json'

module ServiceFlow
  class Cache < Action
    include Helper

    attr_reader :actions, :cache, :params_scheme, :lru_clock

    def initialize(action_or_flow, cache, params_scheme)
      @actions, @cache, @params_scheme = action_or_flow, cache, params_scheme
      @log, @cache_log = [], []
      @lru_clock = 0
    end

    def start(msg_or_params, which = 0)
      res = nil
      lapse = Benchmark.ms do
        params = which == 0 ? _bind(msg_or_params, input) : msg_or_params
        res = cached_get params
      end
      @log << lapse
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
      puts lru_clock

      json, status = nil, nil

      # time cost of cache query
      query_elapse = Benchmark.ms do
        puts 'Query the cache'
        puts params_to_key(params)
        json, status= cache.get params_to_key(params)
      end

      if json.nil? 
        desc = nil
      else 
        data = JSON.parse json
        desc = ::Cache::Descriptor.new(params, data['content'], data['lru_time'])
        if !desc.lru_time.nil? && desc.lru_time < lru_clock
          puts 'fresh the cache!!!'
          refresh_trans = Benchmark.ms do
            data = actions.start(params, 1)
          end
          refresh_caching = Benchmark.ms do
            desc = ::Cache::Descriptor.new(params, data, new_lru_time) 
            cache.set params_to_key(params), desc.to_json
          end
        end
      end 

      status ||= (desc.nil? ? :miss : :equal)

      refresh_trans ||= 0
      refresh_caching ||= 0
      miss_trans, miss_caching = 0, 0

      case status
      when :equal
        puts 'Equal >'
        data = desc.content
      when :contain
        puts 'Contain >'
        # TODO:
        # data = desc.filter status
        data = desc.content
      when :miss
        puts 'Miss >'
        # time cost of transmission when cache missed
        miss_trans = Benchmark.ms do
          data = actions.start(params, 1)
        end
        # NOTE: params here not filtered
        # time cost of set cache
        miss_caching = Benchmark.ms do
          puts 'Miss set the cache >'
          desc = ::Cache::Descriptor.new(params, data, new_lru_time) 
          cache.set params_to_key(params), desc.to_json
        end
      end

      @cache_log << [status, query_elapse, miss_trans, miss_caching, refresh_trans, refresh_caching]
      desc.content
      
    end

    def params_to_key(params)
      params_scheme.map { |p| [p['name'], params[p['name']]] }.join(':')
    end

    def new_lru_time # TODO
      first_action.refresh_freq == 0 ? nil : lru_clock + ( first_action.invoking_freq / first_action.refresh_freq ).round - 1 # decrease 1 or not
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
        counter = Hash.new(0)
        counter[:times] = @cache_log.size
        counter[:size] = cache.size
        @cache_log.each do |log|
          counter[log[0]] += 1
          counter[:query_elapse] += log[1]
          counter[:trans_elapse] += log[2]
          counter[:miss_elapse] += log[3]
        end
        counter
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
