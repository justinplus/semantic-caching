require 'cache'
require 'service_flow/helper'
require 'service_flow/action'

require 'active_support/core_ext/benchmark'
require 'active_support/json'

module ServiceFlow
  class Cache < Action
    include Helper

    attr_reader :actions, :cache, :params_scheme

    def initialize(action_or_flow, cache, params_scheme)
      @actions, @cache, @params_scheme = action_or_flow, cache, params_scheme
      @log, @cache_log = [], []
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

    def input
      @actions.respond_to?(:first_action) ? @actions.first_action.input : @actions.input
      # NOTE: the order
    end

    def cached_get(params)
      json, status = nil, nil

      # time cost of cache query
      query_elapse = Benchmark.ms do
        puts 'Query the cache'
        puts params_to_key(params)
        json, status= cache.get params_to_key(params)
      end

      desc = if json.nil? 
               nil
             else 
               data = JSON.parse json
               ::Cache::Descriptor.new(params, data['content'], data['ttl'])
             end 

      status ||= (desc.nil? ? :miss : :equal)

      trans_elapse, miss_elapse = 0, 0

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
        trans_elapse = Benchmark.ms do
          data = actions.start(params, 1)
        end
        # NOTE: params here not filtered
        desc = ::Cache::Descriptor.new(params, data, nil) 
        # time cost of set cache
        miss_elapse = Benchmark.ms do
          puts 'Miss set the cache >'
          cache.set params_to_key(params), desc.to_json
        end
      end

      @cache_log << [status, query_elapse, trans_elapse, miss_elapse]
      desc.content
      
    end

    def params_to_key(params)
      params_scheme.map { |p| [p['name'], params[p['name']]] }.join(':')
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
      cache.inspect
    end
  end
end
