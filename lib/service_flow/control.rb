require 'service_flow/metrics'
require 'service_flow/helper'

module ServiceFlow
  class Fork
    include Metrics
    
    attr_accessor :prev, :succ, :branches

    def initialize(branches, cache_mode = nil)
      @branches = []
      branches.each { |b| @branches << Flow.new(b, cache_mode) }

      @log = []

    end

    def input
      branches.each_with_object({}) do |br, hsh|
        hsh.merge! br.actions.first.input
      end
    end

    def transform!( cache_mode )
      branches.each { |br| br.transform!(cache_mode) }
    end

    def start(msg_or_params, which = 0)
      case which
      when 0
        res = nil
        elapse = Benchmark.ms do
          res = _start(msg_or_params)
        end
      when 1
        msg = Helper.reverse_bind(msg_or_params, input)
        _msg =  msg.dup

        res = nil
        elapse = Benchmark.ms do
          res = _start(msg)
        end

        _msg.keys.each do |key|
          res.delete key
        end
      end
      @log << elapse
      res
    end

    def log(scope = nil)
      log = @branches.map{ |b| b.log(scope) } 
      log.unshift (scope.nil? || scope == :raw) ?  @log : Helper.cnt_sum_avg(@log)
    end 
    
    def cache_log(scope)
      @branches.map{ |b| b.cache_log(scope) }
    end

    [ 'hit_rate', 'query_time', 'caching_time' ].each do |m|
      define_method m do
        branches.inject(0) { |sum, br| sum + br.public_send(m) } / branches.size
      end
    end

    def valid_rate
      branches.inject(1) { |prod, n| prod * n.valid_rate }
    end

    def invalid_rate
      1 - valid_rate
    end

    def caching_cost
      # TODO:
      branches.map{ |br| br.caching_cost }.max
    end

    def invoking_time
      branches.map{ |br| br.invoking_time }.max
    end

    def split_scheme
      branches.map{ |br| br.split_scheme }
    end

  end
end

